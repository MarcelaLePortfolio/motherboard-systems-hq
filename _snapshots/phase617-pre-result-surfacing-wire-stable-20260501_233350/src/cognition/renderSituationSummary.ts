import type { SituationSummary } from "./situationSummaryComposer";

export function renderSituationSummary(
  summary: SituationSummary
): string {
  return summary.summaryLines.join("\n");
}
