import type { SituationClassification } from "./situation.types";

export interface SituationFrame {
  classification: SituationClassification;

  // Short operator scan label (deterministic, no prose drift)
  title: string;

  // One-sentence meaning of the situation
  summary: string;

  // Optional deeper context (future phases may use)
  detail?: string;

  // Optional render hints (no behavior authority)
  attentionLevel?: "LOW" | "MEDIUM" | "HIGH";

  // Deterministic render ordering hint
  orderHint?: number;
}
