import { ClipboardList } from "lucide-react";
export function Empty({ title, description }: { title: string; description: string }) {
  return <div className="empty"><div className="empty-icon"><ClipboardList size={20} /></div><h3>{title}</h3><p>{description}</p></div>;
}
