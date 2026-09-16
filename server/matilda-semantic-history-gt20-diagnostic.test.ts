import assert from "node:assert/strict";
import test from "node:test";

import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import {
  composeMatildaConversationContext,
} from "./matilda-conversation-context-runtime";

function makeTurn(index: number): MatildaConversationTurn {
  const ordinal = String(index).padStart(2, "0");

  return {
    turn_id: `turn-${ordinal}`,
    project_id: "hq",
    conversation_id: "semantic-history-gt20-diagnostic",
    user_message: `User message ${ordinal}`,
    assistant_reply: `Assistant reply ${ordinal}`,
    created_at: `2026-09-16T08:${ordinal}:00.000Z`,
    interpretation_entry_id: `iel-${ordinal}`,
  } as MatildaConversationTurn;
}

test(
  "characterizes selected-history behavior beyond the production 20-turn candidate boundary",
  () => {
    const allTurns = Array.from(
      { length: 25 },
      (_, offset) => makeTurn(offset + 1),
    );

    const lifecycleEntries = allTurns.map((turn) => ({
      entry_id: turn.interpretation_entry_id,
      supersession_status: "current",
    }));

    const productionWindow = allTurns.slice(-20);

    const emptyProjectContext = {
      excerpts: [],
      projectContextSegmentCandidates: [],
      warning: null,
    } as any;

    const compose = (turns: MatildaConversationTurn[]) =>
      composeMatildaConversationContext({
        turns,
        projectContextRetrieval: emptyProjectContext,
        interpretationLifecycleEntries:
          lifecycleEntries.filter((entry) =>
            turns.some(
              (turn) =>
                turn.interpretation_entry_id ===
                entry.entry_id,
            ),
          ),
      });

    const bounded = compose(productionWindow);
    const deeper = compose(allTurns);

    const boundedIds = bounded.selectedHistory.map(
      (turn) => turn.sourceTurnId,
    );
    const deeperIds = deeper.selectedHistory.map(
      (turn) => turn.sourceTurnId,
    );

    console.log(`TOTAL_FIXTURE_TURNS=${allTurns.length}`);
    console.log(
      `PRODUCTION_CANDIDATE_COUNT=${productionWindow.length}`,
    );
    console.log(
      `PRODUCTION_SELECTED_COUNT=${bounded.selectedHistory.length}`,
    );
    console.log(
      `DEEPER_CANDIDATE_COUNT=${allTurns.length}`,
    );
    console.log(
      `DEEPER_SELECTED_COUNT=${deeper.selectedHistory.length}`,
    );
    console.log(
      `TURN_01_AVAILABLE_AT_20=${boundedIds.includes("turn-01")}`,
    );
    console.log(
      `TURN_01_AVAILABLE_AT_25=${deeperIds.includes("turn-01")}`,
    );

    assert.equal(productionWindow.length, 20);
    assert.equal(bounded.selectedHistory.length, 20);
    assert.equal(deeper.selectedHistory.length, 25);

    assert.equal(
      boundedIds.includes("turn-01"),
      false,
    );

    assert.equal(
      deeperIds.includes("turn-01"),
      true,
    );

    assert.deepEqual(
      boundedIds,
      Array.from(
        { length: 20 },
        (_, offset) =>
          `turn-${String(offset + 6).padStart(2, "0")}`,
      ),
      "20-turn candidate window should expose only turns 06-25",
    );

    assert.deepEqual(
      deeperIds,
      Array.from(
        { length: 25 },
        (_, offset) =>
          `turn-${String(offset + 1).padStart(2, "0")}`,
      ),
      "deeper candidate set should preserve all eligible turns in chronology",
    );

    assert.deepEqual(
      allTurns.map((turn) => turn.turn_id),
      Array.from(
        { length: 25 },
        (_, offset) =>
          `turn-${String(offset + 1).padStart(2, "0")}`,
      ),
      "diagnostic composition must not mutate input ordering",
    );

    console.log(
      "GT20_NON_PRODUCTION_DIAGNOSTIC_CHARACTERIZATION=PASS",
    );
  },
);
