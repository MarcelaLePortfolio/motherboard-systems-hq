import type { GovernanceExecutionBridgeContract } from "../governanceExecutionBridgeContract";

/**
 * Phase 467.0 — Controlled Execution Introduction (First Proof)
 *
 * Structural + pure proof only.
 * No runtime wiring.
 * No worker dispatch.
 * No side effects.
 * No autonomous execution.
 */

export interface GovernedExecutionApproval {
  approved: boolean;
  approval_id: string | null;
  approved_by: string | null;
}

export interface GovernedExecutionProofInput {
  bridge: GovernanceExecutionBridgeContract;
  approval: GovernedExecutionApproval;
}

export interface GovernedExecutionProofResult {
  accepted: boolean;
  blocked_reason: string | null;
  execution: {
    kind: "proof";
    task_id: string | null;
    run_id: string | null;
    outcome: "prepared" | "blocked";
    emitted_events: unknown[];
  };
  reporting: {
    operator_visible: true;
    governance_allow: boolean;
    approval_present: boolean;
  };
}

export function executeGovernedProof(
  input: GovernedExecutionProofInput,
): GovernedExecutionProofResult {
  const governanceAllow = input.bridge.governance.decision.allow === true;
  const approvalPresent = input.approval.approved === true;

  if (!governanceAllow) {
    return {
      accepted: false,
      blocked_reason: "governance_denied",
      execution: {
        kind: "proof",
        task_id: input.bridge.governance.signals.task_id,
        run_id: input.bridge.governance.signals.run_id,
        outcome: "blocked",
        emitted_events: [],
      },
      reporting: {
        operator_visible: true,
        governance_allow: false,
        approval_present: approvalPresent,
      },
    };
  }

  if (!approvalPresent) {
    return {
      accepted: false,
      blocked_reason: "operator_approval_missing",
      execution: {
        kind: "proof",
        task_id: input.bridge.governance.signals.task_id,
        run_id: input.bridge.governance.signals.run_id,
        outcome: "blocked",
        emitted_events: [],
      },
      reporting: {
        operator_visible: true,
        governance_allow: true,
        approval_present: false,
      },
    };
  }

  return {
    accepted: true,
    blocked_reason: null,
    execution: {
      kind: "proof",
      task_id: input.bridge.governance.signals.task_id,
      run_id: input.bridge.governance.signals.run_id,
      outcome: "prepared",
      emitted_events: input.bridge.preparation.emitted_events,
    },
    reporting: {
      operator_visible: true,
      governance_allow: true,
      approval_present: true,
    },
  };
}
