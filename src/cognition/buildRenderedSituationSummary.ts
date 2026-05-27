import { buildSituationSummary } from "./buildSituationSummary";
import { renderSituationSummary } from "./renderSituationSummary";
import type { SystemSituationSignals } from "./situationSummaryInputAdapter";

export function buildRenderedSituationSummary(
  signals: SystemSituationSignals
): string {
  const summary = buildSituationSummary(signals);
  return renderSituationSummary(summary);
}
