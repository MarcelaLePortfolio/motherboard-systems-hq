import { executeGovernedProof } from "../governedExecutionProof";
import {
  executionProofAllowedFixture,
  executionProofGovernanceBlockedFixture,
  executionProofApprovalMissingFixture,
} from "../__fixtures__/governedExecutionProof.fixture";

/**
 * Phase 467.2 — Governed execution proof caseproof
 *
 * Pure evaluation only.
 * No runtime wiring.
 * No worker dispatch.
 * No side effects.
 */

export const governedExecutionAllowedResult =
  executeGovernedProof(executionProofAllowedFixture);

export const governedExecutionGovernanceBlockedResult =
  executeGovernedProof(executionProofGovernanceBlockedFixture);

export const governedExecutionApprovalMissingResult =
  executeGovernedProof(executionProofApprovalMissingFixture);

export const governedExecutionCaseproofSummary = {
  allowed: {
    accepted: governedExecutionAllowedResult.accepted,
    blocked_reason: governedExecutionAllowedResult.blocked_reason,
    outcome: governedExecutionAllowedResult.execution.outcome,
    governance_allow: governedExecutionAllowedResult.reporting.governance_allow,
    approval_present: governedExecutionAllowedResult.reporting.approval_present,
  },
  governance_blocked: {
    accepted: governedExecutionGovernanceBlockedResult.accepted,
    blocked_reason: governedExecutionGovernanceBlockedResult.blocked_reason,
    outcome: governedExecutionGovernanceBlockedResult.execution.outcome,
    governance_allow: governedExecutionGovernanceBlockedResult.reporting.governance_allow,
    approval_present: governedExecutionGovernanceBlockedResult.reporting.approval_present,
  },
  approval_missing: {
    accepted: governedExecutionApprovalMissingResult.accepted,
    blocked_reason: governedExecutionApprovalMissingResult.blocked_reason,
    outcome: governedExecutionApprovalMissingResult.execution.outcome,
    governance_allow: governedExecutionApprovalMissingResult.reporting.governance_allow,
    approval_present: governedExecutionApprovalMissingResult.reporting.approval_present,
  },
};
