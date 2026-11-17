"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Check } from "lucide-react";
import { Button } from "@/components/ui/button";

export function ResolveConflict({
  id,
  revision,
  members,
}: {
  id: string;
  revision: number;
  members: Array<{ inspectionId: string; deviceId: string; localDate: string }>;
}) {
  const router = useRouter();
  const [primary, setPrimary] = useState(members[0]?.inspectionId ?? "");
  const [reason, setReason] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  async function resolve() {
    setSaving(true);
    setError(null);
    const response = await fetch(`/api/v1/conflicts/${id}/resolve`, {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "if-match": `"rev-${revision}"`,
        "idempotency-key": crypto.randomUUID(),
      },
      body: JSON.stringify({ resolution: "CHOOSE_PRIMARY", primaryInspectionId: primary, reason }),
    });
    const body = await response.json();
    setSaving(false);
    if (!response.ok) {
      setError(body.detail ?? "Falha ao resolver.");
      return;
    }
    router.refresh();
  }
  return (
    <div style={{ display: "grid", gap: 10 }}>
      <div className="field">
        <label>Inspeção principal</label>
        <select
          className="select"
          value={primary}
          onChange={(event) => setPrimary(event.target.value)}
        >
          {members.map((member) => (
            <option value={member.inspectionId} key={member.inspectionId}>
              {member.localDate} · {member.deviceId} · {member.inspectionId.slice(0, 8)}
            </option>
          ))}
        </select>
      </div>
      <div className="field">
        <label>Justificativa</label>
        <textarea
          className="textarea"
          value={reason}
          onChange={(event) => setReason(event.target.value)}
        />
      </div>
      {error ? <div className="form-error">{error}</div> : null}
      <Button onClick={resolve} disabled={saving || reason.trim().length < 3}>
        <Check />
        {saving ? "Resolvendo…" : "Confirmar principal"}
      </Button>
    </div>
  );
}
