import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import { AppNav } from "@/components/app-nav";
import { SignOutButton } from "@/components/sign-out-button";
import { authOptions } from "@/features/auth/infrastructure/auth-options";
import { AuthenticationError, getAuthContext } from "@/features/auth/application/auth-context";
import { hasPermission } from "@/features/auth/domain/permissions";

export const dynamic = "force-dynamic";

export default async function PlatformLayout({ children }: { children: React.ReactNode }) {
  const session = await getServerSession(authOptions);
  if (!session?.user) redirect("/login");
  const context = await getAuthContext().catch((error) => {
    if (error instanceof AuthenticationError) redirect("/login");
    throw error;
  });
  return (
    <div className="app-frame">
      <aside className="sidebar">
        <Link className="brand-lockup" href="/">
          <span className="brand-mark">CL</span>
          <span className="brand-copy">
            <span className="brand-name">Checklist Segurança</span>
            <span className="brand-meta">Operação semanal</span>
          </span>
        </Link>
        <AppNav canManageUsers={hasPermission(context.roles, "users:manage")} />
        <div className="sidebar-foot">
          <div className="user-name">{context.displayName}</div>
          <div className="user-role">
            {context.roles.includes("ORG_ADMIN") ? "Administrador" : "Responsável"}
          </div>
          <SignOutButton />
        </div>
      </aside>
      <main className="main">
        <div className="content">{children}</div>
        <footer className="app-footer">Desenvolvido pelo setor de TI</footer>
      </main>
    </div>
  );
}
