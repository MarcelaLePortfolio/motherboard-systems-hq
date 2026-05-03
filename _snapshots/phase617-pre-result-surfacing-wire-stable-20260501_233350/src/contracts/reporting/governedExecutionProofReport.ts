import type { GovernedExecutionProofResult } from "../execution/governedExecutionProof";

/**
 * Phase 467.4 — Operator-visible reporting contract for governed execution proof
 *
 * Structural only.
 * No runtime wiring.
 * No side effects.
 * No authority redistribution.
 */

export interface GovernedExecutionProofReport {
  summary: {
    accepted: boolean;
    blocked_reason: string | null;
    outcome: "prepared" | "blocked";
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

export function buildGovernedExecutionProofReport(
  result: GovernedExecutionProofResult,
): GovernedExecutionProofReport {
  return {
    summary: {
      accepted: result.accepted,
      blocked_reason: result.blocked_reason,
      outcome: result.execution.outcome,
    },
    governance: {
      allow: result.reporting.governance_allow,
    },
    approval: {
      present: result.reporting.approval_present,
    },
    visibility: {
      operator_visible: true,
    },
  };
}
