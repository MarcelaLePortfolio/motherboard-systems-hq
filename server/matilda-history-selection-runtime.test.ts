import test from "node:test";
import assert from "node:assert/strict";

import {
  selectMatildaConversationHistory,
} from "./matilda-history-selection-runtime";

test(
  "selects only eligible uncontaminated history",
  () => {
    const history = [
      {
        sourceTurnId: "turn-1",
        interpretationEntryId: "iel-1",
        userMessage: "User 1",
        assistantReply: "Assistant 1",
        userMessageAuthority: "user_statement",
        assistantReplyAuthority: "assistant_claim",
        contaminationStatus: "unassessed",
      },
      {
        sourceTurnId: "turn-2",
        interpretationEntryId: "iel-2",
        userMessage: "User 2",
        assistantReply: "Assistant 2",
        userMessageAuthority: "user_statement",
        assistantReplyAuthority: "assistant_claim",
        contaminationStatus: "unassessed",
      },
    ];

    const interpretations = [
      {
        interpretationEntryId: "iel-1",
        sourceTurnId: "turn-1",
        supersessionStatus: "current",
        contaminationStatus: "unassessed",
        authorityEvaluation: "eligible",
        contaminationEvaluation: "clear",
      },
      {
        interpretationEntryId: "iel-2",
        sourceTurnId: "turn-2",
        supersessionStatus: "superseded",
        contaminationStatus: "unassessed",
        authorityEvaluation: "ineligible_superseded",
        contaminationEvaluation:
          "detected_superseded_context",
      },
    ];

    const selected =
      selectMatildaConversationHistory(
        history,
        interpretations,
      );

    assert.equal(selected.length, 1);
    assert.equal(
      selected[0].sourceTurnId,
      "turn-1",
    );
  },
);

test(
  "does not mutate history or evaluations",
  () => {
    const history = [];
    const interpretations = [];

    const historyBefore =
      structuredClone(history);

    const interpretationsBefore =
      structuredClone(interpretations);

    selectMatildaConversationHistory(
      history,
      interpretations,
    );

    assert.deepEqual(
      history,
      historyBefore,
    );

    assert.deepEqual(
      interpretations,
      interpretationsBefore,
    );
  },
);

test(
  "returns an empty history when nothing is eligible",
  () => {
    const selected =
      selectMatildaConversationHistory(
        [],
        [],
      );

    assert.deepEqual(
      selected,
      [],
    );
  },
);
