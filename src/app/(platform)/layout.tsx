import { getServerSession } from "next-auth";
import { redirect } from "next/navigation";
import Link from "next/link";
import { AppNav } from "@/components/app-nav";
import { SignOutButton } from "@/components/sign-out-button";
import { authOptions } from "@/features/auth/infrastructure/auth-options";

export const dynamic = "force-dynamic";

export default async function PlatformLayout({ children }: { children: React.ReactNode }) {
  const session = await getServerSession(authOptions);
  if (!session?.user) redirect("/login");
  return <div className="app-frame">
    <aside className="sidebar">
      <Link className="brand-lockup" href="/">
        <span className="brand-mark">C</span>
        <span className="brand-copy"><span className="brand-name">Checklists</span><span className="brand-meta">Operação semanal</span></span>
      </Link>
      <AppNav />
      <div className="sidebar-foot">
        <div className="user-name">{session.user.name}</div>
        <div className="user-role">{session.user.roles.includes("ORG_ADMIN") ? "Administrador" : "Responsável"}</div>
        <SignOutButton />
      </div>
    </aside>
    <main className="main"><div className="content">{children}</div></main>
  </div>;
}
