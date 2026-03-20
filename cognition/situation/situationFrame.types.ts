import type { SituationClassification } from "./situation.types";

export type AttentionLevel = "LOW" | "MEDIUM" | "HIGH";

export interface SituationFrame {
  classification: SituationClassification;

  // Short operator scan label (deterministic, no prose drift)
  title: string;

  // One-sentence meaning of the situation
  summary: string;

  // Optional deeper context (future phases may use)
  detail?: string;

  // Flexible supporting facts for operator understanding
  context?: Record<string, unknown>;

  // Derived from severity (do not set manually)
  attentionLevel: AttentionLevel;

  // Deterministic render ordering hint
  orderHint?: number;
}
