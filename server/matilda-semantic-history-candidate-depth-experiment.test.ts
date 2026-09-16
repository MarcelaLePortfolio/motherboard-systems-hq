import assert from "node:assert/strict";
import test from "node:test";

import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import {
  composeMatildaConversationContext,
} from "./matilda-conversation-context-runtime";

function makeTurn(index: number): MatildaConversationTurn {
  const ordinal = String(index).padStart(3, "0");

  return {
    turn_id: `turn-${ordinal}`,
    project_id: "hq",
    conversation_id: "semantic-history-candidate-depth-experiment",
    user_message:
      `Synthetic diagnostic user message ${ordinal} ` +
      "with stable semantic-history payload.",
    assistant_reply:
      `Synthetic diagnostic Matilda reply ${ordinal} ` +
      "with stable semantic-history payload.",
    created_at: `2026-09-16T${String(
      Math.floor((index - 1) / 60),
    ).padStart(2, "0")}:${String((index - 1) % 60).padStart(
      2,
      "0",
    )}:00.000Z`,
    interpretation_entry_id: `iel-${ordinal}`,
  } as MatildaConversationTurn;
}

function marginalCharacterCost(
  turns: readonly MatildaConversationTurn[],
): number {
  const history = turns
    .flatMap((turn) => [
      "",
      `Conversation source: ${turn.turn_id}`,
      `User: ${turn.user_message}`,
      `Matilda: ${turn.assistant_reply}`,
    ])
    .join("\n");

  const support = [
    "",
    "Allowed conversation support source identifiers:",
    ...turns.map(
      (turn) =>
        `Allowed conversation support source = ${turn.turn_id}`,
    ),
  ].join("\n");

  return `${support}\n${history}`.length;
}

test(
  "characterizes candidate-depth recovery versus marginal prompt cost",
  () => {
    const allTurns = Array.from(
      { length: 100 },
      (_, offset) => makeTurn(offset + 1),
    );

    const lifecycleEntries = allTurns.map((turn) => ({
      entry_id: turn.interpretation_entry_id,
      supersession_status: "current",
    }));

    const emptyProjectContext = {
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning: null,
    } as any;

    const depths = [20, 25, 50, 75, 100] as const;

    const originalOrder = allTurns.map((turn) => turn.turn_id);

    const measurements = depths.map((depth) => {
      const candidates = allTurns.slice(-depth);

      const composed = composeMatildaConversationContext({
        turns: candidates,
        projectContextRetrieval: emptyProjectContext,
        interpretationLifecycleEntries:
          lifecycleEntries.filter((entry) =>
            candidates.some(
              (turn) =>
                turn.interpretation_entry_id ===
                entry.entry_id,
            ),
          ),
      });

      const selectedIds = composed.selectedHistory.map(
        (turn) => turn.sourceTurnId,
      );

      return {
        depth,
        candidateCount: candidates.length,
        selectedCount: composed.selectedHistory.length,
        oldestCandidateId: candidates[0]?.turn_id ?? null,
        oldestSelectedId: selectedIds[0] ?? null,
        newestSelectedId:
          selectedIds[selectedIds.length - 1] ?? null,
        marginalCharacters: marginalCharacterCost(candidates),
        selectedIds,
      };
    });

    for (const measurement of measurements) {
      console.log(
        [
          `DEPTH=${measurement.depth}`,
          `CANDIDATES=${measurement.candidateCount}`,
          `SELECTED=${measurement.selectedCount}`,
          `OLDEST_RECOVERED=${measurement.oldestSelectedId}`,
          `NEWEST_PRESERVED=${measurement.newestSelectedId}`,
          `MARGINAL_CHARACTERS=${measurement.marginalCharacters}`,
        ].join(" "),
      );

      assert.equal(
        measurement.candidateCount,
        measurement.depth,
      );

      assert.equal(
        measurement.selectedCount,
        measurement.depth,
      );

      assert.equal(
        measurement.oldestSelectedId,
        measurement.oldestCandidateId,
      );

      assert.equal(
        measurement.newestSelectedId,
        "turn-100",
      );

      assert.deepEqual(
        measurement.selectedIds,
        allTurns
          .slice(-measurement.depth)
          .map((turn) => turn.turn_id),
        `depth ${measurement.depth} must preserve chronology`,
      );
    }

    assert.deepEqual(
      allTurns.map((turn) => turn.turn_id),
      originalOrder,
      "experiment must not mutate input ordering",
    );

    assert.equal(
      measurements.find((item) => item.depth === 20)
        ?.oldestSelectedId,
      "turn-081",
    );

    assert.equal(
      measurements.find((item) => item.depth === 25)
        ?.oldestSelectedId,
      "turn-076",
    );

    assert.equal(
      measurements.find((item) => item.depth === 50)
        ?.oldestSelectedId,
      "turn-051",
    );

    assert.equal(
      measurements.find((item) => item.depth === 75)
        ?.oldestSelectedId,
      "turn-026",
    );

    assert.equal(
      measurements.find((item) => item.depth === 100)
        ?.oldestSelectedId,
      "turn-001",
    );

    console.log("CANDIDATE_DEPTH_RECOVERY_EXPERIMENT=PASS");
    console.log("SEMANTIC_RANKING=NONE");
    console.log("TOKEN_COUNT_CLAIM=NO");
    console.log("PRODUCTION_DEPTH_ESTABLISHED=NO");
    console.log("OLLAMA_INVOCATION=NO");
  },
);
