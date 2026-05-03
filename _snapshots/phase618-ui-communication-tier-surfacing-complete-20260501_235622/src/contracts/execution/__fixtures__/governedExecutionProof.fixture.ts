import type {
  GovernedExecutionApproval,
  GovernedExecutionProofInput,
} from "../governedExecutionProof";

import { governanceExecutionBridgeTypeproof } from "../../__proofs__/governanceExecutionBridgeContract.typeproof";

/**
 * Phase 467.1 — Fixture inputs for execution proof
 * Covers:
 * - allowed case
 * - governance blocked
 * - approval missing
 */

export const executionProofAllowedFixture: GovernedExecutionProofInput = {
  bridge: governanceExecutionBridgeTypeproof,
  approval: {
    approved: true,
    approval_id: "approval.test.1",
    approved_by: "operator.test",
  },
};

export const executionProofGovernanceBlockedFixture: GovernedExecutionProofInput = {
  bridge: {
    ...governanceExecutionBridgeTypeproof,
    governance: {
      ...governanceExecutionBridgeTypeproof.governance,
      decision: {
        ...governanceExecutionBridgeTypeproof.governance.decision,
        allow: false,
      },
    },
  },
  approval: {
    approved: true,
    approval_id: "approval.test.2",
    approved_by: "operator.test",
  },
};

export const executionProofApprovalMissingFixture: GovernedExecutionProofInput = {
  bridge: governanceExecutionBridgeTypeproof,
  approval: {
    approved: false,
    approval_id: null,
    approved_by: null,
  },
};
