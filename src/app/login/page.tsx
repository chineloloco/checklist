import { Suspense } from "react";
import { redirect } from "next/navigation";
import { getServerSession } from "next-auth";
import { authOptions } from "@/features/auth/infrastructure/auth-options";
import { LoginForm } from "@/features/auth/presentation/login-form";
import { AuthenticationError, getAuthContext } from "@/features/auth/application/auth-context";

export const dynamic = "force-dynamic";

export default async function LoginPage() {
  const session = await getServerSession(authOptions);
  if (session?.user) {
    try {
      await getAuthContext();
      redirect("/");
    } catch (error) {
      if (!(error instanceof AuthenticationError)) throw error;
    }
  }
  const oidcEnabled = Boolean(
    process.env.OIDC_ISSUER && process.env.OIDC_CLIENT_ID && process.env.OIDC_CLIENT_SECRET,
  );
  const credentialsEnabled = process.env.AUTH_ALLOW_CREDENTIALS === "true";
  return (
    <main className="login-page">
      <section className="login-panel">
        <div className="login-brand">
          <span className="brand-mark">CL</span> Checklist Segurança
        </div>
        <div className="login-copy">
          <div className="page-kicker">Login</div>
          <Suspense>
            <LoginForm oidcEnabled={oidcEnabled} credentialsEnabled={credentialsEnabled} />
          </Suspense>
        </div>
        <footer className="login-footer">Desenvolvido pelo setor de TI</footer>
      </section>
    </main>
  );
}
