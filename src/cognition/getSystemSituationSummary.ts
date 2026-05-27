import {
  getSituationSummarySnapshot,
  type SystemSituationSignals,
} from "./index";

export function getSystemSituationSummary(
  signals: SystemSituationSignals
): string {
  const snapshot = getSituationSummarySnapshot(signals);
  return snapshot.rendered;
}
