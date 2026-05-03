import { buildRenderedSituationSummary } from "./buildRenderedSituationSummary";
import type { SystemSituationSignals } from "./situationSummaryInputAdapter";

export function getSituationSummary(
  signals: SystemSituationSignals
): string {

  return buildRenderedSituationSummary(signals);

}
