import {
  composeSituationSummary,
  type SituationSummary,
} from "./situationSummaryComposer";
import {
  adaptSituationSummaryInputs,
  type SystemSituationSignals,
} from "./situationSummaryInputAdapter";

export function buildSituationSummary(
  signals: SystemSituationSignals
): SituationSummary {
  const inputs = adaptSituationSummaryInputs(signals);
  return composeSituationSummary(inputs);
}
