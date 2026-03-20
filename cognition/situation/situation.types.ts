import type { ConfidenceLevel } from "../../scripts/_local/phase92_fix_guidance_imports.sh";

export enum SituationCategory {
  HEALTH = "HEALTH",
  PERFORMANCE = "PERFORMANCE",
  RISK = "RISK",
  INFO = "INFO"
}

export enum SituationSeverity {
  INFO = "INFO",
  WARNING = "WARNING",
  CRITICAL = "CRITICAL"
}

export interface SituationClassification {
  category: SituationCategory;
  severity: SituationSeverity;
  confidence: ConfidenceLevel;
  metadata?: Record<string, unknown>;
  signals?: string[];
}
