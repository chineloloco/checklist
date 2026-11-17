import { compare } from "bcryptjs";
import { and, eq, sql } from "drizzle-orm";
import { employeeNumberSchema } from "@/features/auth/domain/employee-number";
import type { NextAuthOptions } from "next-auth";
import CredentialsProvider from "next-auth/providers/credentials";
import type { OAuthConfig } from "next-auth/providers/oauth";
import { getDb } from "@/infrastructure/db/client";
import { users } from "@/infrastructure/db/schema";
import { type Role } from "@/features/auth/domain/permissions";

type OidcProfile = { sub: string; email?: string; name?: string };

function oidcProvider(): OAuthConfig<OidcProfile> | null {
  const issuer = process.env.OIDC_ISSUER?.replace(/\/$/, "");
  const clientId = process.env.OIDC_CLIENT_ID;
  const clientSecret = process.env.OIDC_CLIENT_SECRET;
  if (!issuer || !clientId || !clientSecret) return null;

  return {
    id: "oidc",
    name: "Identidade corporativa",
    type: "oauth",
    wellKnown: `${issuer}/.well-known/openid-configuration`,
    idToken: true,
    checks: ["pkce", "state"],
    clientId,
    clientSecret,
    authorization: { params: { scope: "openid profile email" } },
    profile(profile) {
      return {
        id: profile.sub,
        email: profile.email,
        name: profile.name ?? profile.email ?? "Usuário",
        organizationId: "",
        roles: [],
      };
    },
  };
}

const providers: NextAuthOptions["providers"] = [];
const oidc = oidcProvider();
if (oidc) providers.push(oidc);

if (process.env.AUTH_ALLOW_CREDENTIALS === "true") {
  providers.push(
    CredentialsProvider({
      name: "Acesso local",
      credentials: {
        employeeNumber: { label: "Matrícula", type: "text" },
        password: { label: "Senha", type: "password" },
      },
      async authorize(credentials) {
        const employeeNumber = employeeNumberSchema.safeParse(credentials?.employeeNumber);
        if (!employeeNumber.success || !credentials?.password) return null;
        const database = getDb();
        const matches = await database
          .select()
          .from(users)
          .where(
            and(
              sql`upper(trim(${users.employeeNumber})) = ${employeeNumber.data}`,
              eq(users.active, true),
            ),
          )
          .limit(2);
        const user = matches.length === 1 ? matches[0] : null;
        if (!user?.passwordHash || !(await compare(credentials.password, user.passwordHash)))
          return null;
        return {
          id: user.id,
          email: user.email,
          name: user.displayName,
          organizationId: user.organizationId,
          roles: user.roles as Role[],
        };
      },
    }),
  );
}

export const authOptions: NextAuthOptions = {
  providers,
  session: { strategy: "jwt", maxAge: 8 * 60 * 60 },
  pages: { signIn: "/login" },
  callbacks: {
    async signIn({ user, account }) {
      if (account?.provider !== "oidc") return true;
      if (!account.providerAccountId || !user.email) return false;
      const database = getDb();
      const [stored] = await database
        .select()
        .from(users)
        .where(and(eq(users.email, user.email.toLowerCase()), eq(users.active, true)))
        .limit(1);
      if (!stored) return false;
      await database
        .update(users)
        .set({
          externalSubject: account.providerAccountId,
          lastLoginAt: new Date(),
          updatedAt: new Date(),
        })
        .where(eq(users.id, stored.id));
      user.id = stored.id;
      user.organizationId = stored.organizationId;
      user.roles = stored.roles as Role[];
      return true;
    },
    async jwt({ token, user }) {
      if (user) {
        token.userId = user.id;
        token.organizationId = user.organizationId;
        token.roles = user.roles;
      }
      return token;
    },
    async session({ session, token }) {
      if (session.user) {
        session.user.id = String(token.userId ?? token.sub ?? "");
        session.user.organizationId = String(token.organizationId ?? "");
        session.user.roles = (token.roles ?? []) as Role[];
      }
      return session;
    },
  },
  cookies: {
    sessionToken: {
      name:
        process.env.NODE_ENV === "production" ? "__Secure-checklist.session" : "checklist.session",
      options: {
        httpOnly: true,
        sameSite: "lax",
        path: "/",
        secure: process.env.NODE_ENV === "production",
      },
    },
  },
};
