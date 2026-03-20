import { ConfidenceLevel } from "../guidance/guidance.types";
import {
  SituationCategory,
  SituationSeverity,
  type SituationClassification,
} from "./situation.types";

export function classifySituation(
  input: Partial<SituationClassification> = {}
): SituationClassification {
  return {
    category: input.category ?? SituationCategory.INFO,
    severity: input.severity ?? SituationSeverity.INFO,
    confidence: input.confidence ?? ConfidenceLevel.LOW,
    metadata: input.metadata,
    signals: input.signals,
  };
}
