import { SituationSeverity } from "./situation.types";
import type { AttentionLevel } from "./situationFrame.types";

export function deriveAttentionLevel(
  severity: SituationSeverity
): AttentionLevel {
  switch (severity) {
    case SituationSeverity.CRITICAL:
      return "HIGH";

    case SituationSeverity.WARNING:
      return "MEDIUM";

    case SituationSeverity.INFO:
    default:
      return "LOW";
  }
}
