import type { GovernancePlaybackState } from "./governance_playback_types";
import {
  reduceGovernancePlaybackState,
  type GovernancePlaybackReducedState,
} from "./governance_playback_reducer";

export interface OperatorGovernancePlaybackView {
  readonly header: {
    readonly decision_id: string;
    readonly cursor_index: number;
    readonly total_events: number;
  };
  readonly summary: GovernancePlaybackReducedState;
  readonly current_event: {
    readonly type: string | null;
    readonly label: string | null;
    readonly timestamp: string | null;
    readonly source: string | null;
    readonly reference_id: string | null;
  };
  readonly navigation: {
    readonly can_step_backward: boolean;
    readonly can_step_forward: boolean;
    readonly is_at_start: boolean;
    readonly is_at_end: boolean;
    readonly progress_ratio: number;
  };
}

export function buildOperatorGovernancePlaybackView(
  state: GovernancePlaybackState,
): OperatorGovernancePlaybackView {
  const summary = reduceGovernancePlaybackState(state);

  return {
    header: {
      decision_id: state.decision_id,
      cursor_index: state.cursor_index,
      total_events: state.total_events,
    },
    summary,
    current_event: {
      type: state.current_event?.type ?? null,
      label: state.current_event?.label ?? null,
      timestamp: state.current_event?.timestamp ?? null,
      source: state.current_event?.source ?? null,
      reference_id: state.current_event?.reference_id ?? null,
    },
    navigation: {
      can_step_backward: summary.can_step_backward,
      can_step_forward: summary.can_step_forward,
      is_at_start: summary.is_at_start,
      is_at_end: summary.is_at_end,
      progress_ratio: summary.progress_ratio,
    },
  };
}
