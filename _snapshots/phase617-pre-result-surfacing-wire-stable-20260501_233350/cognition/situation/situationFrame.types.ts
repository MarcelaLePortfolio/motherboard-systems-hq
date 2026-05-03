import type { SituationClassification } from "./situation.types.ts";

export type AttentionLevel = "LOW" | "MEDIUM" | "HIGH";

export interface SituationFrame {
  classification: SituationClassification;
  title: string;
  summary: string;
  detail?: string;
  context?: Record<string, unknown>;
  attentionLevel: AttentionLevel;
  orderHint?: number;
}
