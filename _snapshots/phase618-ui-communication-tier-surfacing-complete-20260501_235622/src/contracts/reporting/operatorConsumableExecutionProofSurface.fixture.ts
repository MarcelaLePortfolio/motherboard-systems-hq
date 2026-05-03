import { buildOperatorConsumableExecutionProofSurface } from "./operatorConsumableExecutionProofSurface";
import {
  governedExecutionAllowedReport,
  governedExecutionGovernanceBlockedReport,
  governedExecutionApprovalMissingReport,
} from "./governedExecutionProofReport.fixture";

export const operatorSurfaceAllowed =
  buildOperatorConsumableExecutionProofSurface(governedExecutionAllowedReport);

export const operatorSurfaceGovernanceBlocked =
  buildOperatorConsumableExecutionProofSurface(governedExecutionGovernanceBlockedReport);

export const operatorSurfaceApprovalMissing =
  buildOperatorConsumableExecutionProofSurface(governedExecutionApprovalMissingReport);
