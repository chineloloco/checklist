import { createHash, createHmac, randomBytes, randomUUID, timingSafeEqual } from "node:crypto";
import { compare } from "bcryptjs";
import { and, eq, gt, isNull } from "drizzle-orm";
import { getDb } from "@/infrastructure/db/client";
import { mobileAuthSessions, users } from "@/infrastructure/db/schema";
import type { Role } from "@/features/auth/domain/permissions";
import { DomainError } from "@/shared/domain/errors";

const ACCESS_TOKEN_SECONDS = 15 * 60;
const REFRESH_TOKEN_DAYS = 30;
const ISSUER = "checklist-api";
const AUDIENCE = "checklist-mobile";
const VALID_ROLES = new Set<Role>([
  "ORG_ADMIN",
  "TEMPLATE_MANAGER",
  "FLEET_MANAGER",
  "SUPERVISOR",
  "INSPECTOR",
  "AUDITOR"
]);

// Cost-equivalent fallback prevents a missing e-mail from becoming an account oracle.
const DUMMY_PASSWORD_HASH = "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6Ttxp8D7HMXQ8g5xq5F2gWf6zYp6u";

type MobileUser = {
  id: string;
  organizationId: string;
  email: string;
  displayName: string;
  roles: Role[];
};

export type MobileAccessClaims = {
  sub: string;
  organizationId: string;
  email: string;
  displayName: string;
  roles: Role[];
  sessionId: string;
};

export type MobileTokenResponse = {
  accessToken: string;
  accessTokenExpiresAt: string;
  refreshToken: string;
  refreshTokenExpiresAt: string;
  user: {
    id: string;
    email: string;
    displayName: string;
    roles: Role[];
  };
};

function invalidCredentials(): DomainError {
  return new DomainError("INVALID_CREDENTIALS", "E-mail ou senha inválidos.", 401);
}

function invalidRefreshToken(): DomainError {
  return new DomainError("INVALID_REFRESH_TOKEN", "A sessão expirou. Entre novamente.", 401);
}

function signingSecret(): string {
  const secret = process.env.MOBILE_AUTH_SECRET ?? process.env.NEXTAUTH_SECRET;
  if (!secret || secret.length < 32) {
    throw new Error("Configure MOBILE_AUTH_SECRET (ou NEXTAUTH_SECRET) com pelo menos 32 caracteres.");
  }
  return secret;
}

function encode(value: object): string {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}

function tokenHash(token: string): string {
  return createHash("sha256").update(token).digest("hex");
}

function newRefreshToken(): string {
  return randomBytes(48).toString("base64url");
}

function signAccessToken(user: MobileUser, sessionId: string, now = new Date()) {
  const issuedAt = Math.floor(now.getTime() / 1000);
  const expiresAt = issuedAt + ACCESS_TOKEN_SECONDS;
  const header = encode({ alg: "HS256", typ: "JWT" });
  const payload = encode({
    iss: ISSUER,
    aud: AUDIENCE,
    sub: user.id,
    organizationId: user.organizationId,
    email: user.email,
    displayName: user.displayName,
    roles: user.roles,
    sid: sessionId,
    iat: issuedAt,
    exp: expiresAt,
    jti: randomUUID()
  });
  const signature = createHmac("sha256", signingSecret()).update(`${header}.${payload}`).digest("base64url");
  return {
    token: `${header}.${payload}.${signature}`,
    expiresAt: new Date(expiresAt * 1000)
  };
}

function responseFor(user: MobileUser, sessionId: string, refreshToken: string, refreshExpiresAt: Date): MobileTokenResponse {
  const access = signAccessToken(user, sessionId);
  return {
    accessToken: access.token,
    accessTokenExpiresAt: access.expiresAt.toISOString(),
    refreshToken,
    refreshTokenExpiresAt: refreshExpiresAt.toISOString(),
    user: {
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      roles: user.roles
    }
  };
}

export function verifyMobileAccessToken(token: string, now = new Date()): MobileAccessClaims {
  const parts = token.split(".");
  if (parts.length !== 3) throw new Error("Token inválido.");
  const [encodedHeader, encodedPayload, encodedSignature] = parts;
  const expected = createHmac("sha256", signingSecret())
    .update(`${encodedHeader}.${encodedPayload}`)
    .digest();
  const provided = Buffer.from(encodedSignature, "base64url");
  if (provided.length !== expected.length || !timingSafeEqual(provided, expected)) {
    throw new Error("Token inválido.");
  }

  const header = JSON.parse(Buffer.from(encodedHeader, "base64url").toString("utf8")) as Record<string, unknown>;
  const payload = JSON.parse(Buffer.from(encodedPayload, "base64url").toString("utf8")) as Record<string, unknown>;
  const roles = Array.isArray(payload.roles) ? payload.roles.filter((role): role is Role => VALID_ROLES.has(role as Role)) : [];
  const nowSeconds = Math.floor(now.getTime() / 1000);
  if (
    header.alg !== "HS256" ||
    payload.iss !== ISSUER ||
    payload.aud !== AUDIENCE ||
    typeof payload.exp !== "number" ||
    payload.exp <= nowSeconds ||
    typeof payload.sub !== "string" ||
    typeof payload.organizationId !== "string" ||
    typeof payload.email !== "string" ||
    typeof payload.displayName !== "string" ||
    typeof payload.sid !== "string" ||
    roles.length === 0
  ) {
    throw new Error("Token inválido ou expirado.");
  }
  return {
    sub: payload.sub,
    organizationId: payload.organizationId,
    email: payload.email,
    displayName: payload.displayName,
    roles,
    sessionId: payload.sid
  };
}

export async function loginWithPassword(input: {
  email: string;
  password: string;
  deviceId?: string;
}): Promise<MobileTokenResponse> {
  if (process.env.AUTH_ALLOW_CREDENTIALS !== "true") {
    throw new DomainError("PASSWORD_AUTH_DISABLED", "O acesso por usuário e senha está desativado.", 503);
  }
  const database = getDb();
  const matches = await database
    .select()
    .from(users)
    .where(and(eq(users.email, input.email.trim().toLowerCase()), eq(users.active, true)))
    .limit(2);
  const user = matches.length === 1 ? matches[0] : null;
  const passwordMatches = await compare(input.password, user?.passwordHash ?? DUMMY_PASSWORD_HASH);
  if (!user?.passwordHash || !passwordMatches) throw invalidCredentials();

  const refreshToken = newRefreshToken();
  const refreshExpiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000);
  const [session] = await database
    .insert(mobileAuthSessions)
    .values({
      familyId: randomUUID(),
      userId: user.id,
      organizationId: user.organizationId,
      refreshTokenHash: tokenHash(refreshToken),
      deviceId: input.deviceId,
      expiresAt: refreshExpiresAt
    })
    .returning({ id: mobileAuthSessions.id });
  await database.update(users).set({ lastLoginAt: new Date(), updatedAt: new Date() }).where(eq(users.id, user.id));

  return responseFor(
    { ...user, roles: user.roles as Role[] },
    session.id,
    refreshToken,
    refreshExpiresAt
  );
}

export async function rotateRefreshToken(refreshToken: string, deviceId?: string): Promise<MobileTokenResponse> {
  const database = getDb();
  const hash = tokenHash(refreshToken);
  const outcome = await database.transaction(async (transaction) => {
    const [match] = await transaction
      .select({ session: mobileAuthSessions, user: users })
      .from(mobileAuthSessions)
      .innerJoin(users, eq(users.id, mobileAuthSessions.userId))
      .where(eq(mobileAuthSessions.refreshTokenHash, hash))
      .limit(1);

    if (!match) return null;
    if (match.session.revokedAt) {
      await transaction
        .update(mobileAuthSessions)
        .set({ revokedAt: new Date() })
        .where(and(eq(mobileAuthSessions.familyId, match.session.familyId), isNull(mobileAuthSessions.revokedAt)));
      return null;
    }
    if (!match.user.active || match.session.expiresAt <= new Date()) {
      await transaction
        .update(mobileAuthSessions)
        .set({ revokedAt: new Date() })
        .where(and(eq(mobileAuthSessions.familyId, match.session.familyId), isNull(mobileAuthSessions.revokedAt)));
      return null;
    }

    const nextSessionId = randomUUID();
    const claimed = await transaction
      .update(mobileAuthSessions)
      .set({ revokedAt: new Date(), lastUsedAt: new Date() })
      .where(
        and(
          eq(mobileAuthSessions.id, match.session.id),
          isNull(mobileAuthSessions.revokedAt),
          gt(mobileAuthSessions.expiresAt, new Date())
        )
      )
      .returning({ id: mobileAuthSessions.id });
    if (claimed.length === 0) {
      await transaction
        .update(mobileAuthSessions)
        .set({ revokedAt: new Date() })
        .where(and(eq(mobileAuthSessions.familyId, match.session.familyId), isNull(mobileAuthSessions.revokedAt)));
      return null;
    }

    const nextToken = newRefreshToken();
    const nextExpiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000);
    const [nextSession] = await transaction
      .insert(mobileAuthSessions)
      .values({
        id: nextSessionId,
        familyId: match.session.familyId,
        userId: match.user.id,
        organizationId: match.user.organizationId,
        refreshTokenHash: tokenHash(nextToken),
        deviceId: deviceId ?? match.session.deviceId ?? undefined,
        expiresAt: nextExpiresAt
      })
      .returning({ id: mobileAuthSessions.id });
    await transaction
      .update(mobileAuthSessions)
      .set({ replacedById: nextSession.id })
      .where(eq(mobileAuthSessions.id, match.session.id));

    return {
      user: { ...match.user, roles: match.user.roles as Role[] },
      sessionId: nextSession.id,
      refreshToken: nextToken,
      refreshExpiresAt: nextExpiresAt
    };
  });

  if (!outcome) throw invalidRefreshToken();
  return responseFor(outcome.user, outcome.sessionId, outcome.refreshToken, outcome.refreshExpiresAt);
}

export async function revokeRefreshToken(refreshToken: string): Promise<void> {
  await getDb()
    .update(mobileAuthSessions)
    .set({ revokedAt: new Date() })
    .where(and(eq(mobileAuthSessions.refreshTokenHash, tokenHash(refreshToken)), isNull(mobileAuthSessions.revokedAt)));
}
