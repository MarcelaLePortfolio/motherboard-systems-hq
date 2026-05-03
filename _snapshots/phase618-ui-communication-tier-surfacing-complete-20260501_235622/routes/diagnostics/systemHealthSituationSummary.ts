import { getSystemSituationSummary } from "../../src/cognition";
import type { SystemSituationSignals } from "../../src/cognition";

export type SystemHealthSituationSummaryPayload = {
  situationSummary: string;
};

export function buildSystemHealthSituationSummaryPayload(
  signals: SystemSituationSignals
): SystemHealthSituationSummaryPayload {
  return {
    situationSummary: getSystemSituationSummary(signals),
  };
}
