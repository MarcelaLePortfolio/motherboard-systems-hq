import type { GovernanceDecisionId } from "./governance_investigation_types";
import type { GovernanceTimelineEvent } from "./governance_timeline_types";

export interface GovernancePlaybackState {
  readonly decision_id: GovernanceDecisionId;
  readonly cursor_index: number;
  readonly timeline: readonly GovernanceTimelineEvent[];
  readonly current_event: GovernanceTimelineEvent | null;
  readonly total_events: number;
}

export interface GovernancePlaybackSeed {
  readonly decision_id: GovernanceDecisionId;
  readonly timeline: readonly GovernanceTimelineEvent[];
  readonly cursor_index?: number;
}

export function createGovernancePlaybackState(
  seed: GovernancePlaybackSeed,
): GovernancePlaybackState {
  const totalEvents = seed.timeline.length;

  if (totalEvents === 0) {
    return {
      decision_id: seed.decision_id,
      cursor_index: -1,
      timeline: Object.freeze([...seed.timeline]),
      current_event: null,
      total_events: 0,
    };
  }

  const requestedCursor = seed.cursor_index ?? 0;
  const cursorIndex = Math.min(Math.max(requestedCursor, 0), totalEvents - 1);

  return {
    decision_id: seed.decision_id,
    cursor_index: cursorIndex,
    timeline: Object.freeze([...seed.timeline]),
    current_event: seed.timeline[cursorIndex] ?? null,
    total_events: totalEvents,
  };
}
