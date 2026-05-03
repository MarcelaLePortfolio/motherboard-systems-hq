import type { SituationFrame } from "./situationFrame.types.ts";

function safeString(value: unknown, fallback: string): string {
  if (typeof value !== "string") return fallback;

  const trimmed = value.trim();

  if (trimmed.length === 0) return fallback;

  return trimmed;
}

function safeOrder(value: unknown): number | undefined {
  if (typeof value !== "number") return undefined;

  if (!Number.isFinite(value)) return undefined;

  if (value < 0) return 0;

  return Math.floor(value);
}

export function normalizeSituationFrame(
  frame: SituationFrame
): SituationFrame {

  return {
    ...frame,

    title: safeString(
      frame.title,
      "Situation"
    ),

    summary: safeString(
      frame.summary,
      "No summary available"
    ),

    orderHint: safeOrder(
      frame.orderHint
    ),

    context:
      frame.context &&
      typeof frame.context === "object"
        ? frame.context
        : undefined
  };
}
