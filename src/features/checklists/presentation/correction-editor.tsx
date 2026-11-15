"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { Save, X } from "lucide-react";
import { Button } from "@/components/ui/button";

type Answer = { itemId: string; result: "C" | "NC" | "NA" | null; observation: string | null };
type Item = { itemId: string; text: string; sourcePrintedNumber: string | null };

export function CorrectionEditor({ inspectionId, revision, identification, observations, items, initialAnswers }: { inspectionId: string; revision: number; identification: Record<string, unknown>; observations: string | null; items: Item[]; initialAnswers: Answer[] }) {
  const router = useRouter(); const [open, setOpen] = useState(false); const [answers, setAnswers] = useState(initialAnswers); const [reason, setReason] = useState(""); const [error, setError] = useState<string | null>(null); const [saving, setSaving] = useState(false);
  function setResult(itemId: string, result: "C" | "NC" | "NA") { setAnswers((current) => { const found = current.find((item) => item.itemId === itemId); return found ? current.map((item) => item.itemId === itemId ? { ...item, result } : item) : [...current, { itemId, result, observation: null }]; }); }
  async function save() { setSaving(true); setError(null); const response = await fetch(`/api/v1/inspections/${inspectionId}/corrections`, { method:"POST", headers:{"content-type":"application/json","if-match":`"rev-${revision}"`,"idempotency-key":crypto.randomUUID()}, body:JSON.stringify({ correctionReason:reason, identification, observations, responses:answers }) }); const body=await response.json(); setSaving(false); if(!response.ok){setError(body.detail??"Falha ao corrigir.");return;} setOpen(false); router.refresh(); }
  if (!open) return <Button variant="secondary" onClick={() => setOpen(true)}>Corrigir inspeção</Button>;
  return <section className="panel" style={{marginTop:16}}><div className="panel-header"><div><h2 className="panel-title">Nova correção auditada</h2><div className="panel-subtitle">A revisão atual será preservada.</div></div><Button variant="ghost" onClick={() => setOpen(false)}><X />Fechar</Button></div><div className="panel-body" style={{display:"grid",gap:14}}>
    <div className="field"><label htmlFor="reason">Motivo da correção</label><textarea className="textarea" id="reason" value={reason} onChange={(event)=>setReason(event.target.value)} required /></div>
    <div className="data-table-wrap"><table className="data-table"><thead><tr><th>Item</th><th>Resultado corrigido</th></tr></thead><tbody>{items.map((item)=>{const value=answers.find((answer)=>answer.itemId===item.itemId)?.result;return <tr key={item.itemId}><td><span className="item-number">{item.sourcePrintedNumber}</span>{item.text}</td><td><div style={{display:"flex",gap:6}}>{(["C","NC","NA"] as const).map((result)=><button className={`matrix-value matrix-value-${result.toLowerCase()}`} style={{opacity:value===result?1:.35,border:0,cursor:"pointer"}} type="button" key={result} onClick={()=>setResult(item.itemId,result)}>{result}</button>)}</div></td></tr>})}</tbody></table></div>
    {error?<div className="form-error" role="alert">{error}</div>:null}<div><Button disabled={saving||reason.trim().length<3} onClick={save}><Save />{saving?"Salvando…":"Registrar correção"}</Button></div>
  </div></section>;
}
