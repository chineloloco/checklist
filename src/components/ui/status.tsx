export function Status({ value, label }: { value: string; label?: string }) {
  const normalized = value.toLowerCase().replaceAll("_", "-");
  return <span className={`status status-${normalized}`}>{label ?? value}</span>;
}
