import {
  OperationalConfidence,
  OperationalConfidenceContribution,
} from "./operationalConfidence.types";
import { synthesizeOperationalConfidence } from "./operationalConfidence.synthesizer";

export function selectOperationalConfidence(
  governanceContributions: OperationalConfidenceContribution[]
): OperationalConfidence {
  return synthesizeOperationalConfidence(governanceContributions);
}
