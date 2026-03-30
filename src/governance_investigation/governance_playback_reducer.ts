import type { GovernancePlaybackState } from "./governance_playback_types";

export interface GovernancePlaybackReducedState {
  readonly decision_id: string;
  readonly cursor_index: number;
  readonly total_events: number;
  readonly current_event_type: string | null;
  readonly current_event_label: string | null;
  readonly has_current_event: boolean;
  readonly can_step_backward: boolean;
  readonly can_step_forward: boolean;
  readonly is_at_start: boolean;
  readonly is_at_end: boolean;
  readonly progress_ratio: number;
}

export function reduceGovernancePlaybackState(
  state: GovernancePlaybackState,
): GovernancePlaybackReducedState {
  const hasCurrentEvent = state.current_event !== null;
  const isEmpty = state.total_events === 0;
  const isAtStart = !isEmpty && state.cursor_index === 0;
  const isAtEnd = !isEmpty && state.cursor_index === state.total_events - 1;

  return {
    decision_id: state.decision_id,
    cursor_index: state.cursor_index,
    total_events: state.total_events,
    current_event_type: state.current_event?.type ?? null,
    current_event_label: state.current_event?.label ?? null,
    has_current_event: hasCurrentEvent,
    can_step_backward: !isEmpty && !isAtStart,
    can_step_forward: !isEmpty && !isAtEnd,
    is_at_start: isAtStart,
    is_at_end: isAtEnd,
    progress_ratio: isEmpty ? 0 : (state.cursor_index + 1) / state.total_events,
  };
}
