import assert from "node:assert/strict";

import {
  assembleLivingDraftPackageReadCollection,
  assembleLivingDraftPackageReadModel,
} from "./package-read-model-assembler";
import type { LivingDraftPackageReadRecord } from "./package-read-repository";

function record(
  overrides: Partial<LivingDraftPackageReadRecord> = {},
): LivingDraftPackageReadRecord {
  return {
    draft_package_id: "draft-1",
    lineage_id: "lineage-1",
    current_interpretation: "Interpretation",
    proposed_work: "Work",
    proposed_artifacts: null,
    in_scope: null,
    out_of_scope: null,
    constraints: null,
    expected_outcome: "Outcome",
    unresolved_questions: null,
    evidence_entry_ids: "[]",
    status: "draft_non_authoritative",
    created_at: "2026-07-31T10:00:00Z",
    updated_at: "2026-07-31T11:00:00Z",
    project_id: "hq",
    conversation_id: "conversation-1",
    ...overrides,
  };
}

const model = assembleLivingDraftPackageReadModel(record());

assert.equal(model.id, "draft-1");
assert.equal(model.title, "Outcome");
assert.equal(model.summary, "Interpretation");
assert.equal(model.status, "needs_review");

const fallback = assembleLivingDraftPackageReadModel(
  record({
    expected_outcome: " ",
    current_interpretation: " ",
    proposed_work: "Fallback work",
    conversation_id: " ",
  }),
);

assert.equal(fallback.title, "Untitled Living Draft Package");
assert.equal(fallback.summary, "Fallback work");
assert.equal(fallback.conversation_id, null);

const collection =
  assembleLivingDraftPackageReadCollection("hq", [
    record(),
    record({ draft_package_id: "draft-2" }),
  ]);

assert.equal(collection.packages.length, 2);

assert.throws(
  () =>
    assembleLivingDraftPackageReadCollection("hq", [
      record({
        draft_package_id: "other",
        project_id: "other",
      }),
    ]),
);

console.log("Package Read model assembler tests passed.");
