"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Tabela } from "@/components/ui/tabela";
import { userRoleLabels, type ManagedUser } from "@/features/users/domain/user";

export function UserManager({
  users,
  currentUserId,
}: {
  users: ManagedUser[];
  currentUserId: string;
}) {
  const router = useRouter();
  const [editing, setEditing] = useState<ManagedUser | null>(null);
  const [open, setOpen] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [message, setMessage] = useState("");

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const values = new FormData(form);
    setSaving(true);
    setError("");
    setMessage("");
    try {
      const password = String(values.get("password") ?? "");
      const response = await fetch(editing ? `/api/v1/users/${editing.id}` : "/api/v1/users", {
        method: editing ? "PATCH" : "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({
          displayName: values.get("displayName"),
          employeeNumber: values.get("employeeNumber"),
          roles: values.getAll("roles"),
          password: password || undefined,
          ...(editing ? { active: values.get("active") === "on" } : {}),
        }),
      });
      const body = await response.json();
      if (!response.ok)
        throw new Error(
          body.errors?.[0]?.message ?? body.detail ?? "Não foi possível salvar o usuário.",
        );
      form.reset();
      setOpen(false);
      setEditing(null);
      setMessage("Usuário salvo. O acesso usa a matrícula e a senha cadastradas.");
      router.refresh();
    } catch (error) {
      setError(error instanceof Error ? error.message : "Falha ao salvar.");
    } finally {
      setSaving(false);
    }
  }

  return (
    <>
      <section className="panel" style={{ marginBottom: 16 }}>
        <div className="panel-header">
          <div>
            <h2 className="panel-title">Contas de acesso</h2>
            <p className="panel-subtitle">
              Cada pessoa deve usar sua própria conta para identificar suas ações.
            </p>
          </div>
          <Button
            disabled={saving}
            onClick={() => {
              setEditing(null);
              setOpen(true);
              setError("");
              setMessage("");
            }}
          >
            Novo usuário
          </Button>
        </div>
        {open && (
          <div className="panel-body">
            <form key={editing?.id ?? "new"} className="form-grid" onSubmit={submit}>
              <h3 style={{ gridColumn: "1 / -1" }}>
                {editing ? `Editar ${editing.displayName}` : "Cadastrar usuário"}
              </h3>
              <div className="field">
                <label htmlFor="user-name">Nome completo</label>
                <input
                  id="user-name"
                  className="input"
                  name="displayName"
                  defaultValue={editing?.displayName}
                  required
                  minLength={2}
                  maxLength={200}
                  disabled={saving}
                  autoComplete="name"
                />
              </div>
              <div className="field">
                <label htmlFor="user-employee-number">Matrícula</label>
                <input
                  id="user-employee-number"
                  className="input"
                  name="employeeNumber"
                  defaultValue={editing?.employeeNumber ?? ""}
                  required
                  maxLength={50}
                  disabled={saving}
                  autoComplete="off"
                  autoCapitalize="characters"
                  spellCheck={false}
                />
                <small>Use a matrícula da pessoa, preservando os zeros iniciais.</small>
              </div>
              <div className="field">
                <label htmlFor="user-password">
                  {editing ? "Nova senha (opcional)" : "Senha inicial"}
                </label>
                <input
                  id="user-password"
                  className="input"
                  type="password"
                  name="password"
                  required={!editing}
                  minLength={10}
                  disabled={saving}
                  autoComplete="new-password"
                />
                <small>
                  Mínimo de 10 caracteres.{editing ? " Deixe vazio para manter a atual." : ""}
                </small>
              </div>
              <fieldset className="field" style={{ gridColumn: "1 / -1" }} disabled={saving}>
                <legend>Perfis de acesso</legend>
                <div style={{ display: "flex", flexWrap: "wrap", gap: 16 }}>
                  {Object.entries(userRoleLabels).map(([role, label]) => (
                    <label key={role} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                      <input
                        type="checkbox"
                        name="roles"
                        value={role}
                        defaultChecked={
                          editing
                            ? editing.roles.includes(role as keyof typeof userRoleLabels)
                            : role === "INSPECTOR"
                        }
                      />
                      {label}
                    </label>
                  ))}
                </div>
              </fieldset>
              {editing && (
                <label style={{ display: "flex", alignItems: "center", gap: 8 }}>
                  <input
                    type="checkbox"
                    name="active"
                    defaultChecked={editing.active}
                    disabled={saving || editing.id === currentUserId}
                  />
                  Conta ativa
                  {editing.id === currentUserId && <input type="hidden" name="active" value="on" />}
                </label>
              )}
              <div style={{ gridColumn: "1 / -1", display: "flex", gap: 8 }}>
                <Button disabled={saving}>{saving ? "Salvando…" : "Salvar usuário"}</Button>
                <Button
                  type="button"
                  variant="secondary"
                  disabled={saving}
                  onClick={() => {
                    setOpen(false);
                    setError("");
                  }}
                >
                  Cancelar
                </Button>
              </div>
              {error && (
                <p role="alert" className="form-error" style={{ gridColumn: "1 / -1" }}>
                  {error}
                </p>
              )}
            </form>
          </div>
        )}
        {message && (
          <p role="status" className="form-success" style={{ margin: 16 }}>
            {message}
          </p>
        )}
      </section>
      <section className="panel">
        <Tabela
          legenda="Usuários"
          dados={users}
          chaveLinha={(user) => user.id}
          colunas={[
            { chave: "displayName", titulo: "Nome" },
            {
              chave: "employeeNumber",
              titulo: "Matrícula",
              render: (user) => user.employeeNumber ?? "Pendente de cadastro",
            },
            {
              chave: "roles",
              titulo: "Perfis",
              render: (user) => user.roles.map((role) => userRoleLabels[role]).join(", "),
            },
            {
              chave: "active",
              titulo: "Situação",
              render: (user) => (user.active ? "Ativo" : "Desativado"),
            },
          ]}
          acoes={(user) => (
            <Button
              variant="secondary"
              disabled={saving}
              onClick={() => {
                setEditing(user);
                setOpen(true);
                setError("");
                setMessage("");
                window.scrollTo({ top: 0, behavior: "smooth" });
              }}
            >
              Editar
            </Button>
          )}
        />
      </section>
    </>
  );
}
