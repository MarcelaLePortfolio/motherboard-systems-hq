import type { GovernancePlaybackState } from "./governance_playback_types";

export function playbackNext(
  state: GovernancePlaybackState,
): GovernancePlaybackState {
  if (state.total_events === 0) return state;

  const nextIndex = Math.min(
    state.cursor_index + 1,
    state.total_events - 1,
  );

  return {
    ...state,
    cursor_index: nextIndex,
    current_event: state.timeline[nextIndex] ?? null,
  };
}

export function playbackPrevious(
  state: GovernancePlaybackState,
): GovernancePlaybackState {
  if (state.total_events === 0) return state;

  const prevIndex = Math.max(
    state.cursor_index - 1,
    0,
  );

  return {
    ...state,
    cursor_index: prevIndex,
    current_event: state.timeline[prevIndex] ?? null,
  };
}

export function playbackJump(
  state: GovernancePlaybackState,
  index: number,
): GovernancePlaybackState {
  if (state.total_events === 0) return state;

  const bounded = Math.min(
    Math.max(index, 0),
    state.total_events - 1,
  );

  return {
    ...state,
    cursor_index: bounded,
    current_event: state.timeline[bounded] ?? null,
  };
}

export function playbackStart(
  state: GovernancePlaybackState,
): GovernancePlaybackState {
  if (state.total_events === 0) return state;

  return {
    ...state,
    cursor_index: 0,
    current_event: state.timeline[0] ?? null,
  };
}

export function playbackEnd(
  state: GovernancePlaybackState,
): GovernancePlaybackState {
  if (state.total_events === 0) return state;

  const last = state.total_events - 1;

  return {
    ...state,
    cursor_index: last,
    current_event: state.timeline[last] ?? null,
  };
}
