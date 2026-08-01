import assert from "node:assert/strict";
import test from "node:test";

import type { ApprovalRequestSourceRecord } from "./approval-request-repository";

import {
  assembleApprovalRequestReadCollection,
  assembleApprovalRequestReadModel,
} from "./approval-request-model-assembler";

function createSource(
  overrides: Partial<ApprovalRequestSourceRecord> = {},
): ApprovalRequestSourceRecord {
  return {
    draft_package_id: "draft-hq-pending",
    lineage_id: "lineage-hq-pending",
    project_id: "hq",
    conversation_id: "conversation-hq",
    current_interpretation: "Prepare the Approval Request read model.",
    proposed_work: "Assemble an executive-facing read model.",
    proposed_artifacts: "Approval Request model and tests.",
    in_scope: "Canonical Package approval projection.",
    out_of_scope: "Decision execution.",
    constraints: "Read-only and project-scoped.",
    expected_outcome: "One deterministic pending request.",
    unresolved_questions: null,
    evidence_entry_ids: JSON.stringify([
      "evidence-1",
      "evidence-2",
      "evidence-1",
    ]),
    source_draft_status: "draft_non_authoritative",
    created_at: "2026-08-01T07:00:00.000Z",
    updated_at: "2026-08-01T07:30:00.000Z",
    ...overrides,
  };
}

test("assembles a deterministic Approval Request", () => {
  const request =
    assembleApprovalRequestReadModel(createSource());

  assert.equal(
    request.approval_request_id,
    "canonical_package_approval:draft-hq-pending",
  );

  assert.deepEqual(
    request.available_decisions,
    ["approve_canonical_package"],
  );

  assert.deepEqual(
    request.evidence.evidence_entry_ids,
    ["evidence-1", "evidence-2"],
  );
});

test("assembles a project-scoped collection", () => {
  const collection =
    assembleApprovalRequestReadCollection("hq", [
      createSource({ draft_package_id: "draft-1" }),
      createSource({ draft_package_id: "draft-2" }),
    ]);

  assert.equal(collection.project_id, "hq");
  assert.equal(collection.requests.length, 2);
});

test("rejects cross-project sources", () => {
  assert.throws(
    () =>
      assembleApprovalRequestReadCollection("hq", [
        createSource({ project_id: "other" }),
      ]),
    /project does not match/,
  );
});

test("rejects invalid evidence JSON", () => {
  assert.throws(
    () =>
      assembleApprovalRequestReadModel(
        createSource({
          evidence_entry_ids: "not-json",
        }),
      ),
    /invalid evidence_entry_ids JSON/,
  );
});
