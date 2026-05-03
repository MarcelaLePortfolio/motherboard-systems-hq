import { buildGovernedExecutionProofReport } from "./governedExecutionProofReport";
import {
  governedExecutionAllowedResult,
  governedExecutionGovernanceBlockedResult,
  governedExecutionApprovalMissingResult,
} from "../execution/__proofs__/governedExecutionProof.caseproof";

export const governedExecutionAllowedReport =
  buildGovernedExecutionProofReport(governedExecutionAllowedResult);

export const governedExecutionGovernanceBlockedReport =
  buildGovernedExecutionProofReport(governedExecutionGovernanceBlockedResult);

export const governedExecutionApprovalMissingReport =
  buildGovernedExecutionProofReport(governedExecutionApprovalMissingResult);
