import type { GovernancePlaybackState } from "./governance_playback_types";

export function isPlaybackCursorValid(
  state: GovernancePlaybackState,
): boolean {
  if (state.total_events === 0) {
    return state.cursor_index === -1;
  }

  return (
    state.cursor_index >= 0 &&
    state.cursor_index < state.total_events
  );
}

export function isPlaybackCurrentEventValid(
  state: GovernancePlaybackState,
): boolean {
  if (state.total_events === 0) {
    return state.current_event === null;
  }

  return (
    state.current_event ===
    state.timeline[state.cursor_index]
  );
}

export function isPlaybackTotalValid(
  state: GovernancePlaybackState,
): boolean {
  return state.total_events === state.timeline.length;
}

export function verifyPlaybackState(
  state: GovernancePlaybackState,
): boolean {
  return (
    isPlaybackCursorValid(state) &&
    isPlaybackCurrentEventValid(state) &&
    isPlaybackTotalValid(state)
  );
}
