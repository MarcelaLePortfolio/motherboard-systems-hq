import {
  playbackEnd,
  playbackJump,
  playbackNext,
  playbackPrevious,
  playbackStart,
} from "./governance_playback_navigation";
import {
  createGovernancePlaybackState,
  type GovernancePlaybackState,
} from "./governance_playback_types";
import { verifyPlaybackState } from "./governance_playback_invariants";
import type { GovernanceTimelineEvent } from "./governance_timeline_types";

export interface GovernancePlaybackProofResult {
  readonly initial_valid: boolean;
  readonly next_valid: boolean;
  readonly previous_valid: boolean;
  readonly start_valid: boolean;
  readonly end_valid: boolean;
  readonly jump_valid: boolean;
  readonly all_valid: boolean;
}

export interface GovernancePlaybackProofSeed {
  readonly decision_id: string;
  readonly timeline: readonly GovernanceTimelineEvent[];
}

function verifyState(state: GovernancePlaybackState): boolean {
  return verifyPlaybackState(state);
}

export function runGovernancePlaybackProof(
  seed: GovernancePlaybackProofSeed,
): GovernancePlaybackProofResult {
  const initial = createGovernancePlaybackState({
    decision_id: seed.decision_id,
    timeline: seed.timeline,
  });

  const steppedNext = playbackNext(initial);
  const steppedPrevious = playbackPrevious(steppedNext);
  const movedStart = playbackStart(steppedNext);
  const movedEnd = playbackEnd(initial);
  const jumpedMiddle = playbackJump(
    initial,
    seed.timeline.length > 0 ? Math.floor(seed.timeline.length / 2) : 0,
  );

  const result: GovernancePlaybackProofResult = {
    initial_valid: verifyState(initial),
    next_valid: verifyState(steppedNext),
    previous_valid: verifyState(steppedPrevious),
    start_valid: verifyState(movedStart),
    end_valid: verifyState(movedEnd),
    jump_valid: verifyState(jumpedMiddle),
    all_valid: false,
  };

  return {
    ...result,
    all_valid:
      result.initial_valid &&
      result.next_valid &&
      result.previous_valid &&
      result.start_valid &&
      result.end_valid &&
      result.jump_valid,
  };
}
