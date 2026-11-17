import { z } from "zod";

// Keep this as text: leading zeroes are part of an employee number.
export const employeeNumberSchema = z
  .string()
  .trim()
  .toUpperCase()
  .min(1, "Informe a matrícula.")
  .max(50)
  .regex(
    /^[A-Z0-9][A-Z0-9._/-]*$/,
    "Use letras, números, ponto, hífen, barra ou sublinhado na matrícula.",
  );
