import assert from "node:assert/strict";
import test from "node:test";

import type {
  InterpretationEvidenceLedgerReadEntry,
} from "../../db/matilda-interpretation-runtime";

import {
  adaptInterpretationEvidenceForAtlas,
} from "./atlas-preexecution-read-model";

const entry: InterpretationEvidenceLedgerReadEntry = {
  entry_id: "iel-atlas-preexecution-1",
  created_at: "2026-09-16T00:00:00.000Z",
  actor: "matilda",
  project_id: "hq",
  conversation_id: "conversation-1",
  interpretation_event: "interpretation",
  minimum_sufficient_context: "minimum context",
  supporting_raw_evidence: "raw evidence",
  matilda_observation: "durable observation",
  unresolved_questions: "remaining question",
  lineage_references: "lineage-1",
  investigationLifecycle: null,
  packageSemantics: null,
  supersession_status: "current",
};

test(
  "Atlas pre-execution adapter preserves canonical IEL evidence",
  () => {
    const observation =
      adaptInterpretationEvidenceForAtlas(entry, {
        projectId: "hq",
        conversationId: "conversation-1",
      });

    assert.equal(
      observation.entryId,
      "iel-atlas-preexecution-1",
    );
    assert.equal(observation.projectId, "hq");
    assert.equal(
      observation.conversationId,
      "conversation-1",
    );
    assert.equal(
      observation.matildaObservation,
      "durable observation",
    );
    assert.equal(
      observation.minimumSufficientContext,
      "minimum context",
    );
    assert.equal(
      observation.supersessionStatus,
      "current",
    );
  },
);

test(
  "Atlas pre-execution adapter fails closed across project scope",
  () => {
    assert.throws(
      () =>
        adaptInterpretationEvidenceForAtlas(entry, {
          projectId: "other-project",
          conversationId: "conversation-1",
        }),
      /project_id scope/,
    );
  },
);

test(
  "Atlas pre-execution adapter fails closed across conversation scope",
  () => {
    assert.throws(
      () =>
        adaptInterpretationEvidenceForAtlas(entry, {
          projectId: "hq",
          conversationId: "other-conversation",
        }),
      /conversation_id scope/,
    );
  },
);
