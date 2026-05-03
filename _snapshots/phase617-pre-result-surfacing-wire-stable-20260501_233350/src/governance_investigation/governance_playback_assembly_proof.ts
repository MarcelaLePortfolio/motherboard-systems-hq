import type { GovernanceDecisionTrace } from "./governance_decision_trace";
import { assembleGovernancePlayback } from "./governance_playback_assembly";

export interface GovernancePlaybackAssemblyProofResult {
  readonly playback_valid: boolean;
  readonly operator_view_matches_playback: boolean;
  readonly dashboard_contract_matches_view: boolean;
  readonly dashboard_status_matches_playback: boolean;
  readonly all_valid: boolean;
}

export function runGovernancePlaybackAssemblyProof(
  trace: GovernanceDecisionTrace,
  cursor_index?: number,
): GovernancePlaybackAssemblyProofResult {

  const assembled = assembleGovernancePlayback({
    trace,
    cursor_index,
  });

  const playbackValid = assembled.is_valid;

  const operatorViewMatchesPlayback =
    assembled.operator_view.header.decision_id ===
      assembled.playback.decision_id &&
    assembled.operator_view.header.cursor_index ===
      assembled.playback.cursor_index &&
    assembled.operator_view.header.total_events ===
      assembled.playback.total_events &&
    assembled.operator_view.current_event.type ===
      (assembled.playback.current_event?.type ?? null) &&
    assembled.operator_view.current_event.label ===
      (assembled.playback.current_event?.label ?? null);

  const dashboardContractMatchesView =
    assembled.dashboard_contract.view.header.decision_id ===
      assembled.operator_view.header.decision_id &&
    assembled.dashboard_contract.view.header.cursor_index ===
      assembled.operator_view.header.cursor_index &&
    assembled.dashboard_contract.view.header.total_events ===
      assembled.operator_view.header.total_events;

  const dashboardStatusMatchesPlayback =
    assembled.dashboard_contract.status.total_events ===
      assembled.playback.total_events &&
    (
      assembled.playback.total_events === 0
        ? assembled.dashboard_contract.status.current_position === null
        : assembled.dashboard_contract.status.current_position ===
          assembled.playback.cursor_index + 1
    );

  return {
    playback_valid: playbackValid,
    operator_view_matches_playback: operatorViewMatchesPlayback,
    dashboard_contract_matches_view: dashboardContractMatchesView,
    dashboard_status_matches_playback: dashboardStatusMatchesPlayback,
    all_valid:
      playbackValid &&
      operatorViewMatchesPlayback &&
      dashboardContractMatchesView &&
      dashboardStatusMatchesPlayback,
  };
}
