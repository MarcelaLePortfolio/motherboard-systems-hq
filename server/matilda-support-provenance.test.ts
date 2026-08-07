import assert from "node:assert/strict";
import test from "node:test";

import {
  createMatildaPersistedSupportProvenance,
  readMatildaPersistedSupportProvenance,
} from "./matilda-support-provenance";

test(
  "support provenance round-trips through IEL raw evidence",
  () => {
    const provenance =
      createMatildaPersistedSupportProvenance(
        [
          {
            type: "conversation_turn",
            sourceTurnId: "turn-1",
          },
          {
            type: "project_context_excerpt",
            relativePath:
              "server/matilda-chat-workflow.ts",
            lineNumber: 155,
          },
        ],
        true,
      );

    const raw = JSON.stringify({
      support_source_references:
        provenance.supportSourceReferences,
      evidence_sufficient:
        provenance.evidenceSufficient,
    });

    assert.deepEqual(
      readMatildaPersistedSupportProvenance(raw),
      provenance,
    );
  },
);

test(
  "missing persisted provenance returns null",
  () => {
    assert.equal(
      readMatildaPersistedSupportProvenance(
        JSON.stringify({
          user_message: "Hello",
        }),
      ),
      null,
    );
  },
);

test(
  "malformed persisted provenance returns null",
  () => {
    assert.equal(
      readMatildaPersistedSupportProvenance(
        JSON.stringify({
          support_source_references: [
            {
              type: "conversation_turn",
            },
          ],
          evidence_sufficient: true,
        }),
      ),
      null,
    );
  },
);
