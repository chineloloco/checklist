"use client";

import { useState } from "react";
import { signIn } from "next-auth/react";
import { useRouter, useSearchParams } from "next/navigation";
import { LogIn } from "lucide-react";
import { Button } from "@/components/ui/button";

export function LoginForm({
  oidcEnabled,
  credentialsEnabled,
}: {
  oidcEnabled: boolean;
  credentialsEnabled: boolean;
}) {
  const router = useRouter();
  const search = useSearchParams();
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function submit(event: React.FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = new FormData(event.currentTarget);
    setLoading(true);
    setError(null);
    const outcome = await signIn("credentials", {
      employeeNumber: form.get("employeeNumber"),
      password: form.get("password"),
      redirect: false,
    });
    setLoading(false);
    if (!outcome?.ok) {
      setError("Matrícula ou senha inválidas.");
      return;
    }
    router.push(search.get("callbackUrl") ?? "/");
    router.refresh();
  }

  return (
    <div className="login-form">
      {oidcEnabled ? (
        <Button type="button" onClick={() => signIn("oidc", { callbackUrl: "/" })}>
          <LogIn /> Entrar com identidade corporativa
        </Button>
      ) : null}
      {credentialsEnabled ? (
        <form className="login-form" onSubmit={submit}>
          <div className="field">
            <label htmlFor="employeeNumber">Matrícula</label>
            <input
              className="input"
              id="employeeNumber"
              name="employeeNumber"
              autoComplete="username"
              autoCapitalize="characters"
              spellCheck={false}
              maxLength={50}
              required
            />
          </div>
          <div className="field">
            <label htmlFor="password">Senha</label>
            <input
              className="input"
              id="password"
              name="password"
              type="password"
              autoComplete="current-password"
              required
            />
          </div>
          {error ? (
            <div className="form-error" role="alert">
              {error}
            </div>
          ) : null}
          <Button disabled={loading} type="submit">
            <LogIn /> {loading ? "Entrando…" : "Entrar"}
          </Button>
        </form>
      ) : null}
      {!oidcEnabled && !credentialsEnabled ? (
        <div className="notice notice-amber">Nenhum provedor de autenticação foi configurado.</div>
      ) : null}
    </div>
  );
}
