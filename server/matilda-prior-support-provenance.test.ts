import assert from "node:assert/strict";
import test from "node:test";

import type {
  MatildaSelectedHistoryTurn,
} from "./matilda-history-selection-runtime";
import {
  recoverMatildaPriorSupportProvenance,
} from "./matilda-prior-support-provenance";

function createSelectedTurn(
  overrides: Partial<MatildaSelectedHistoryTurn> = {},
): MatildaSelectedHistoryTurn {
  return {
    sourceTurnId: "turn-1",
    interpretationEntryId: "iel-1",
    userMessage: "Should we preserve the workflow?",
    assistantReply:
      "Yes. Preserving it maintains the established invariant.",
    userMessageAuthority: "user_statement",
    assistantReplyAuthority: "assistant_claim",
    contaminationStatus: "unassessed",
    ...overrides,
  };
}

test(
  "recovers sufficient provenance from the immediately preceding selected turn",
  () => {
    const result =
      recoverMatildaPriorSupportProvenance(
        [
          createSelectedTurn({
            sourceTurnId: "turn-old",
            interpretationEntryId: "iel-old",
          }),
          createSelectedTurn({
            sourceTurnId: "turn-current",
            interpretationEntryId: "iel-current",
          }),
        ],
        [
          {
            entry_id: "iel-old",
            supporting_raw_evidence:
              JSON.stringify({
                support_source_references: [],
                evidence_sufficient: false,
              }),
          },
          {
            entry_id: "iel-current",
            supporting_raw_evidence:
              JSON.stringify({
                support_source_references: [
                  {
                    type: "conversation_turn",
                    sourceTurnId: "turn-old",
                  },
                ],
                evidence_sufficient: true,
              }),
          },
        ],
      );

    assert.equal(result.status, "sufficient");
    assert.equal(
      result.provenance?.evidenceSufficient,
      true,
    );
    assert.deepEqual(
      result.provenance?.supportSourceReferences,
      [
        {
          type: "conversation_turn",
          sourceTurnId: "turn-old",
        },
      ],
    );
  },
);

test(
  "recovers insufficient provenance deterministically",
  () => {
    const result =
      recoverMatildaPriorSupportProvenance(
        [createSelectedTurn()],
        [
          {
            entry_id: "iel-1",
            supporting_raw_evidence:
              JSON.stringify({
                support_source_references: [],
                evidence_sufficient: false,
              }),
          },
        ],
      );

    assert.equal(result.status, "insufficient");
    assert.equal(
      result.provenance?.evidenceSufficient,
      false,
    );
  },
);

test(
  "returns unavailable when the selected prior turn has no matching IEL entry",
  () => {
    const result =
      recoverMatildaPriorSupportProvenance(
        [createSelectedTurn()],
        [],
      );

    assert.deepEqual(result, {
      status: "unavailable",
      provenance: null,
    });
  },
);

test(
  "returns unavailable when persisted provenance is absent",
  () => {
    const result =
      recoverMatildaPriorSupportProvenance(
        [createSelectedTurn()],
        [
          {
            entry_id: "iel-1",
            supporting_raw_evidence:
              JSON.stringify({
                user_message: "Legacy turn",
              }),
          },
        ],
      );

    assert.deepEqual(result, {
      status: "unavailable",
      provenance: null,
    });
  },
);

test(
  "returns unavailable when selected history is empty",
  () => {
    const result =
      recoverMatildaPriorSupportProvenance(
        [],
        [
          {
            entry_id: "iel-1",
            supporting_raw_evidence:
              JSON.stringify({
                support_source_references: [],
                evidence_sufficient: true,
              }),
          },
        ],
      );

    assert.deepEqual(result, {
      status: "unavailable",
      provenance: null,
    });
  },
);
