"use client";

import { usePathname } from "next/navigation";
import Link from "next/link";
import {
  BookOpen,
  Building2,
  ClipboardCheck,
  LayoutDashboard,
  ScrollText,
  ShieldAlert,
  Users,
} from "lucide-react";

const items = [
  { href: "/", label: "Painel", icon: LayoutDashboard },
  { href: "/checklists", label: "Checklists", icon: ClipboardCheck },
  { href: "/modelos", label: "Modelos", icon: BookOpen },
  { href: "/cadastros", label: "Cadastros", icon: Building2 },
  { href: "/conflitos", label: "Conflitos", icon: ShieldAlert },
  { href: "/auditoria", label: "Auditoria", icon: ScrollText },
];

export function AppNav({ canManageUsers = false }: { canManageUsers?: boolean }) {
  const pathname = usePathname();
  return (
    <nav className="nav-list" aria-label="Navegação principal">
      {[
        ...items,
        ...(canManageUsers ? [{ href: "/usuarios", label: "Usuários", icon: Users }] : []),
      ].map(({ href, label, icon: Icon }) => {
        const active = href === "/" ? pathname === "/" : pathname.startsWith(href);
        return (
          <Link
            className="nav-link"
            data-active={active}
            href={href}
            key={href}
            aria-current={active ? "page" : undefined}
          >
            <Icon aria-hidden="true" />
            <span className="nav-label">{label}</span>
          </Link>
        );
      })}
    </nav>
  );
}
