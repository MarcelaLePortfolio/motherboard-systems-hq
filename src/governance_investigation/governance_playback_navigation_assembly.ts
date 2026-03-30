import type { GovernancePlaybackAssembly } from "./governance_playback_assembly";
import { assembleGovernancePlayback } from "./governance_playback_assembly";
import {
  playbackEnd,
  playbackJump,
  playbackNext,
  playbackPrevious,
  playbackStart,
} from "./governance_playback_navigation";

function reassembleFromPlayback(
  assembly: GovernancePlaybackAssembly,
  cursor_index: number,
): GovernancePlaybackAssembly {

  return assembleGovernancePlayback({
    trace: {
      decision: {
        decision_id: assembly.playback.decision_id,
        timestamp: assembly.operator_view.current_event.timestamp ?? "",
        policy_id: "unknown",
        disposition: "observe",
        reference_id: assembly.operator_view.current_event.reference_id ?? "",
      },
      explanation: null,
      audit: [],
      signals: [],
      policy: null,
      investigation: {
        decision_id: assembly.playback.decision_id,
        timestamp: assembly.operator_view.current_event.timestamp ?? "",
        policy_id: "unknown",
        signals: [],
        decision: {
          decision_id: assembly.playback.decision_id,
          timestamp: assembly.operator_view.current_event.timestamp ?? "",
          policy_id: "unknown",
          disposition: "observe",
          reference_id: assembly.operator_view.current_event.reference_id ?? "",
        },
        explanation_id: null,
        audit_refs: [],
      },
      timeline: assembly.playback.timeline,
    },
    cursor_index,
  });

}

export function assemblePlaybackNext(
  assembly: GovernancePlaybackAssembly,
): GovernancePlaybackAssembly {

  const nextState = playbackNext(assembly.playback);

  return reassembleFromPlayback(
    assembly,
    nextState.cursor_index,
  );
}

export function assemblePlaybackPrevious(
  assembly: GovernancePlaybackAssembly,
): GovernancePlaybackAssembly {

  const prevState = playbackPrevious(assembly.playback);

  return reassembleFromPlayback(
    assembly,
    prevState.cursor_index,
  );
}

export function assemblePlaybackJump(
  assembly: GovernancePlaybackAssembly,
  index: number,
): GovernancePlaybackAssembly {

  const jumped = playbackJump(
    assembly.playback,
    index,
  );

  return reassembleFromPlayback(
    assembly,
    jumped.cursor_index,
  );
}

export function assemblePlaybackStart(
  assembly: GovernancePlaybackAssembly,
): GovernancePlaybackAssembly {

  const start = playbackStart(assembly.playback);

  return reassembleFromPlayback(
    assembly,
    start.cursor_index,
  );
}

export function assemblePlaybackEnd(
  assembly: GovernancePlaybackAssembly,
): GovernancePlaybackAssembly {

  const end = playbackEnd(assembly.playback);

  return reassembleFromPlayback(
    assembly,
    end.cursor_index,
  );
}
