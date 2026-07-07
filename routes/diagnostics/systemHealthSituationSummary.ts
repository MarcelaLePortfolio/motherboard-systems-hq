import express from "express";
const router = express.Router();

import { getSystemSituationSummary } from "../../src/cognition.js";
import type { SystemSituationSignals } from "../../src/cognition.js";

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
