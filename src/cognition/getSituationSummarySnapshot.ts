import { buildSituationSummary } from "./buildSituationSummary";
import { renderSituationSummary } from "./renderSituationSummary";
import type { SituationSummary } from "./situationSummaryComposer";
import type { SystemSituationSignals } from "./situationSummaryInputAdapter";

export type SituationSummarySnapshot = {
  summary: SituationSummary;
  rendered: string;
};

export function getSituationSummarySnapshot(
  signals: SystemSituationSignals
): SituationSummarySnapshot {
  const summary = buildSituationSummary(signals);
  const rendered = renderSituationSummary(summary);

  return {
    summary,
    rendered,
  };
}
