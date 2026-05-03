/**
 * Phase 467.6 — Operator-Consumable Execution Proof Exposure
 *
 * Structural only.
 * No runtime wiring.
 * No execution enablement.
 * No authority redistribution.
 */

import type { GovernedExecutionProofReport } from "./governedExecutionProofReport";

export interface OperatorConsumableExecutionProofSurface {
  panel: {
    kind: "governed_execution_proof";
    status: "accepted" | "blocked";
    headline: string;
    detail: string;
  };
  governance: {
    allow: boolean;
  };
  approval: {
    present: boolean;
  };
  visibility: {
    operator_visible: true;
  };
}

export function buildOperatorConsumableExecutionProofSurface(
  report: GovernedExecutionProofReport,
): OperatorConsumableExecutionProofSurface {
  const status = report.summary.accepted ? "accepted" : "blocked";

  const headline =
    status === "accepted"
      ? "Governed execution proof accepted"
      : "Governed execution proof blocked";

  const detail =
    report.summary.blocked_reason === "governance_denied"
      ? "Blocked by governance policy."
      : report.summary.blocked_reason === "operator_approval_missing"
      ? "Awaiting operator approval."
      : "Execution prepared and approved.";

  return {
    panel: {
      kind: "governed_execution_proof",
      status,
      headline,
      detail,
    },
    governance: {
      allow: report.governance.allow,
    },
    approval: {
      present: report.approval.present,
    },
    visibility: {
      operator_visible: true,
    },
  };
}
