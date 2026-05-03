import type { OperatorGovernancePlaybackView } from "./governance_operator_playback_view";

export interface GovernanceDashboardPlaybackContract {
  readonly view: OperatorGovernancePlaybackView;
  readonly controls: {
    readonly can_step_backward: boolean;
    readonly can_step_forward: boolean;
    readonly can_jump: boolean;
    readonly can_reset: boolean;
  };
  readonly status: {
    readonly is_empty: boolean;
    readonly is_valid: boolean;
    readonly current_position: number | null;
    readonly total_events: number;
  };
}

export function createGovernanceDashboardPlaybackContract(
  view: OperatorGovernancePlaybackView,
): GovernanceDashboardPlaybackContract {
  const totalEvents = view.header.total_events;
  const isEmpty = totalEvents === 0;

  return {
    view,
    controls: {
      can_step_backward: view.navigation.can_step_backward,
      can_step_forward: view.navigation.can_step_forward,
      can_jump: !isEmpty,
      can_reset: !isEmpty && !view.navigation.is_at_start,
    },
    status: {
      is_empty: isEmpty,
      is_valid: !isEmpty
        ? view.header.cursor_index >= 0 &&
          view.header.cursor_index < totalEvents
        : view.header.cursor_index === -1,
      current_position: isEmpty ? null : view.header.cursor_index + 1,
      total_events: totalEvents,
    },
  };
}
