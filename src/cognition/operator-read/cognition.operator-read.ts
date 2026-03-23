/**
 * Phase 101.3 — Operator Read Integration
 *
 * Purpose:
 * Provide a read-only operator-facing cognition projection
 * without introducing runtime mutation or UI behavior changes.
 *
 * Rules:
 * - Read-only integration
 * - No reducers
 * - No wiring
 * - No runtime mutation
 * - No behavior change
 * - Deterministic projection only
 */

import type {
  CognitionContractEnvelope,
  GovernanceCognitionContract,
  OperatorGuidanceContract,
  SituationSummaryContract
} from "../contracts/cognition.contracts";
import {
  selectGovernanceCognition,
  selectHasGovernanceCognition,
  selectHasOperatorGuidance,
  selectHasSituationSummary,
  selectOperatorGuidance,
  selectSituationSummary
} from "../selectors/cognition.selectors";

export interface OperatorCognitionReadModel {
  hasSituation: boolean;
  hasGuidance: boolean;
  hasGovernance: boolean;
  situation: SituationSummaryContract | null;
  guidance: OperatorGuidanceContract[];
  governance: GovernanceCognitionContract[];
}

export function buildOperatorCognitionReadModel(
  envelope: CognitionContractEnvelope
): OperatorCognitionReadModel {
  return {
    hasSituation: selectHasSituationSummary(envelope),
    hasGuidance: selectHasOperatorGuidance(envelope),
    hasGovernance: selectHasGovernanceCognition(envelope),
    situation: selectSituationSummary(envelope),
    guidance: selectOperatorGuidance(envelope),
    governance: selectGovernanceCognition(envelope)
  };
}
