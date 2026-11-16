import { Suspense } from "react";
import { redirect } from "next/navigation";
import { getServerSession } from "next-auth";
import { authOptions } from "@/features/auth/infrastructure/auth-options";
import { LoginForm } from "@/features/auth/presentation/login-form";

export const dynamic = "force-dynamic";

export default async function LoginPage() {
  const session = await getServerSession(authOptions);
  if (session?.user) redirect("/");
  const oidcEnabled = Boolean(process.env.OIDC_ISSUER && process.env.OIDC_CLIENT_ID && process.env.OIDC_CLIENT_SECRET);
  const credentialsEnabled = process.env.AUTH_ALLOW_CREDENTIALS === "true";
  return <main className="login-page">
    <section className="login-panel">
      <div className="login-brand"><span className="brand-mark">C</span> Checklists operacionais</div>
      <div className="login-copy">
        <div className="page-kicker">Acesso à operação</div>
        <h1>A semana inteira, sem perder uma inspeção.</h1>
        <p>Consulte versões, acompanhe datas esperadas e resolva conflitos de dispositivos sem apagar o histórico.</p>
        <Suspense><LoginForm oidcEnabled={oidcEnabled} credentialsEnabled={credentialsEnabled} /></Suspense>
      </div>
    </section>
    <aside className="login-side" aria-hidden="true">
      <div className="login-ledger">
        <div className="ledger-head"><span>Veículos leves · VL-017</span><span>10/11</span><span>12/11</span><span>14/11</span></div>
        <div className="ledger-row"><span>Carteira de habilitação</span><span className="ledger-c">C</span><span className="ledger-c">C</span><span className="ledger-c">C</span></div>
        <div className="ledger-row"><span>Pneus dianteiros (3 mm)</span><span className="ledger-c">C</span><span className="ledger-nc">NC</span><span className="ledger-c">C</span></div>
        <div className="ledger-row"><span>Extintor validade</span><span className="ledger-c">C</span><span className="ledger-c">C</span><span className="ledger-na">NA</span></div>
        <div className="ledger-row"><span>Luz de Ré e Luz de Freio</span><span className="ledger-c">C</span><span className="ledger-c">C</span><span className="ledger-c">C</span></div>
        <div className="ledger-row"><span>Vazamentos</span><span className="ledger-c">C</span><span className="ledger-c">C</span><span className="ledger-nc">NC</span></div>
      </div>
    </aside>
  </main>;
}
