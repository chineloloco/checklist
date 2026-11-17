import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: { default: "Checklists operacionais", template: "%s · Checklists" },
  description: "Gestão semanal de inspeções de veículos e equipamentos.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="pt-BR">
      <body>{children}</body>
    </html>
  );
}
