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

import type { ConfidenceLevel } from "../guidance/guidance.types";

export interface SituationClassification {
  category: SituationCategory;
  severity: SituationSeverity;
  confidence: ConfidenceLevel;
}
