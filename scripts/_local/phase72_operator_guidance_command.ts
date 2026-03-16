/*
PHASE 72 — OPERATOR GUIDANCE COMMAND ENTRYPOINT
Read-only operator guidance command.

STRICT:
- NO reducer mutation
- NO telemetry mutation
- NO DB writes
- NO automation authority
*/

import {
  interpretOperatorGuidance,
  summarizeGuidance,
  type OperatorSignals
} from "./phase72_operator_guidance_interpreter";
import { classifyOperatorSafety } from "./phase72_operator_safety_classifier";

export type OperatorGuidanceCommandResult = {
  systemState: string;
  riskLevel: "SAFE" | "CAUTION" | "RISK";
  recommendedAction: string;
  safeToContinue: boolean;
  blocking: boolean;
  reasons: string[];
};

export function runOperatorGuidanceCommand(
  signals: OperatorSignals
): OperatorGuidanceCommandResult {
  const guidance = interpretOperatorGuidance(signals);
  const safety = classifyOperatorSafety(signals);
  const summary = summarizeGuidance(guidance);

  return {
    systemState: summary.state,
    riskLevel: summary.risk,
    recommendedAction: summary.next,
    safeToContinue: summary.continue,
    blocking: safety.blocking,
    reasons: safety.reason
  };
}

if (require.main === module) {
  const raw = process.argv[2];
  const parsed: OperatorSignals = raw ? JSON.parse(raw) : {};

  const result = runOperatorGuidanceCommand(parsed);
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
}
