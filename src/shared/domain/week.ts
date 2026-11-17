const DATE_ONLY = /^\d{4}-\d{2}-\d{2}$/;

export function assertDateOnly(value: string): void {
  if (!DATE_ONLY.test(value)) throw new Error(`Data inválida: ${value}`);
}

export function dateToUtc(value: string): Date {
  assertDateOnly(value);
  const [year, month, day] = value.split("-").map(Number);
  const date = new Date(Date.UTC(year, month - 1, day));
  if (formatDateOnly(date) !== value) throw new Error(`Data inválida: ${value}`);
  return date;
}

export function formatDateOnly(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function mondayOf(value: string): string {
  const date = dateToUtc(value);
  const day = date.getUTCDay();
  const daysSinceMonday = (day + 6) % 7;
  date.setUTCDate(date.getUTCDate() - daysSinceMonday);
  return formatDateOnly(date);
}

export function isDateInWeek(localDate: string, weekStartDate: string): boolean {
  const date = dateToUtc(localDate).getTime();
  const start = dateToUtc(weekStartDate).getTime();
  const end = start + 6 * 86_400_000;
  return date >= start && date <= end;
}

export function addDays(value: string, days: number): string {
  const date = dateToUtc(value);
  date.setUTCDate(date.getUTCDate() + days);
  return formatDateOnly(date);
}

export function todayInTimeZone(timeZone: string, now = new Date()): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(now);
}
