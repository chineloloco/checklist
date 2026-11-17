import { redirect } from "next/navigation";
import { PageHeader } from "@/components/ui/page-header";
import { getAuthContext } from "@/features/auth/application/auth-context";
import { hasPermission } from "@/features/auth/domain/permissions";
import { UserService } from "@/features/users/application/user-service";
import { UserManager } from "@/features/users/presentation/user-manager";

export default async function UsersPage() {
  const context = await getAuthContext();
  if (!hasPermission(context.roles, "users:manage")) redirect("/");
  const users = await new UserService().list(context);
  return (
    <>
      <PageHeader
        kicker="Administração"
        title="Usuários"
        description="Cadastre as pessoas que acessam o painel e o aplicativo, defina permissões e controle as contas ativas."
      />
      <UserManager users={users} currentUserId={context.userId} />
    </>
  );
}
