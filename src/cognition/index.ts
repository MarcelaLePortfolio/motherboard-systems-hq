export {
  composeSituationSummary,
  type SituationSummary,
  type SituationSummaryInputs,
  type StabilityState,
  type ExecutionRiskState,
  type CognitionState,
  type SignalCoherenceState,
  type OperatorAttentionState,
  type GovernanceCognitionState,
} from "./situationSummaryComposer";

export {
  adaptSituationSummaryInputs,
  isGovernanceAwarenessSurface,
  sanitizeGovernanceAwarenessSurface,
  type SystemSituationSignals,
} from "./situationSummaryInputAdapter";

export {
  buildGovernanceAwarenessSignals,
} from "../../shared/types/governance";

export type {
  GovernanceAwarenessSurface,
  GovernanceAwarenessStructure,
  GovernanceAwarenessSignal,
  GovernanceAwarenessSignals,
  GovernanceAuthorityBoundaryAwareness,
  GovernanceVerificationSummary,
} from "../../shared/types/governance";

export { buildSituationSummary } from "./buildSituationSummary";
export { renderSituationSummary } from "./renderSituationSummary";
export { buildRenderedSituationSummary } from "./buildRenderedSituationSummary";
export { getSituationSummary } from "./getSituationSummary";
export { getSystemSituationSummary } from "./getSystemSituationSummary";

export {
  getSituationSummarySnapshot,
  type SituationSummarySnapshot,
} from "./getSituationSummarySnapshot";
