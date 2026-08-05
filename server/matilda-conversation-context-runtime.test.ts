import test from "node:test";
import assert from "node:assert/strict";

import type {
  MatildaConversationTurn,
} from "../db/matilda-conversation-runtime";
import type {
  MatildaProjectContextRetrievalResult,
} from "./matilda-project-context-retrieval";
import {
  composeMatildaConversationContext,
} from "./matilda-conversation-context-runtime";

function createTurn(
  overrides: Partial<MatildaConversationTurn> = {},
): MatildaConversationTurn {
  return {
    turn_id: "turn-1",
    project_id: "hq",
    conversation_id: "conversation-1",
    user_message: "Hello",
    assistant_reply: "Hi",
    interpretation_entry_id: "iel-1",
    project_context_evidence_trace: null,
    created_at: "2026-08-05T00:00:00.000Z",
    ...overrides,
  };
}

function createRetrieval():
  MatildaProjectContextRetrievalResult {
  return {
    projectId: "hq",
    projectRootPath: "/tmp/project",
    available: true,
    searched: true,
    queryTerms: [],
    excerpts: [],
    warning: null,
  };
}

test(
  "composes all read models without mutating inputs",
  () => {
    const turns = [createTurn()];
    const retrieval = createRetrieval();

    const turnsBefore = structuredClone(turns);
    const retrievalBefore =
      structuredClone(retrieval);

    const context =
      composeMatildaConversationContext({
        turns,
        projectContextRetrieval: retrieval,
      });

    assert.equal(context.history.length, 1);
    assert.equal(context.interpretations.length, 1);
    assert.equal(
      context.evaluatedInterpretations.length,
      1,
    );
    assert.equal(
      context.contaminationEvaluations.length,
      1,
    );
    assert.equal(
      context.selectedHistory.length,
      0,
    );

    assert.deepEqual(turns, turnsBefore);
    assert.deepEqual(
      retrieval,
      retrievalBefore,
    );
  },
);

test(
  "selects eligible history only",
  () => {
    const context =
      composeMatildaConversationContext({
        turns: [
          createTurn({
            turn_id: "turn-current",
            interpretation_entry_id:
              "iel-current",
          }),
        ],
        projectContextRetrieval:
          createRetrieval(),
        interpretationLifecycleEntries: [
          {
            entry_id: "iel-current",
            supersession_status:
              "current",
          },
        ],
      });

    assert.deepEqual(
      context.selectedHistory.map(
        (turn) => turn.sourceTurnId,
      ),
      ["turn-current"],
    );
  },
);

test(
  "passes project evidence through unchanged",
  () => {
    const retrieval =
      createRetrieval();

    retrieval.warning = "warning";

    const context =
      composeMatildaConversationContext({
        turns: [],
        projectContextRetrieval:
          retrieval,
      });

    assert.equal(
      context.projectContextWarning,
      "warning",
    );

    assert.deepEqual(
      context.selectedHistory,
      [],
    );
  },
);
