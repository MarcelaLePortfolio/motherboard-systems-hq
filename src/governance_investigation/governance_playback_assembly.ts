import type { GovernanceDecisionTrace } from "./governance_decision_trace";
import {
  createGovernancePlaybackState,
  type GovernancePlaybackState,
} from "./governance_playback_types";
import {
  buildOperatorGovernancePlaybackView,
  type OperatorGovernancePlaybackView,
} from "./governance_operator_playback_view";
import {
  createGovernanceDashboardPlaybackContract,
  type GovernanceDashboardPlaybackContract,
} from "./governance_dashboard_playback_contract";
import { verifyPlaybackState } from "./governance_playback_invariants";

export interface GovernancePlaybackAssembly {
  readonly playback: GovernancePlaybackState;
  readonly operator_view: OperatorGovernancePlaybackView;
  readonly dashboard_contract: GovernanceDashboardPlaybackContract;
  readonly is_valid: boolean;
}

export interface GovernancePlaybackAssemblySeed {
  readonly trace: GovernanceDecisionTrace;
  readonly cursor_index?: number;
}

export function assembleGovernancePlayback(
  seed: GovernancePlaybackAssemblySeed,
): GovernancePlaybackAssembly {
  const playback = createGovernancePlaybackState({
    decision_id: seed.trace.decision.decision_id,
    timeline: seed.trace.timeline,
    cursor_index: seed.cursor_index,
  });

  const operatorView = buildOperatorGovernancePlaybackView(playback);
  const dashboardContract =
    createGovernanceDashboardPlaybackContract(operatorView);

  return {
    playback,
    operator_view: operatorView,
    dashboard_contract: dashboardContract,
    is_valid: verifyPlaybackState(playback),
  };
}
