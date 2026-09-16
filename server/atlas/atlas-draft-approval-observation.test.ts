import assert from "node:assert/strict";
import test from "node:test";

import type {
  LivingDraftPackageReadRecord,
} from "../../db/package-read-repository";

import type {
  ApprovalRequestSourceRecord,
} from "../../db/approval-request-repository";

import {
  adaptLivingDraftForAtlas,
  adaptPendingApprovalForAtlas,
} from "./atlas-draft-approval-observation";

const livingDraft: LivingDraftPackageReadRecord = {
  draft_package_id: "draft-1",
  lineage_id: "lineage-1",
  current_interpretation: "Current interpretation",
  proposed_work: "Proposed work",
  proposed_artifacts: null,
  in_scope: "In scope",
  out_of_scope: null,
  constraints: "Constraint",
  expected_outcome: "Expected outcome",
  unresolved_questions: null,
  evidence_entry_ids: '["iel-1"]',
  status: "draft",
  created_at: "2026-09-16T20:00:00.000Z",
  updated_at: "2026-09-16T20:01:00.000Z",
  project_id: "hq",
  conversation_id: "conversation-1",
};

const pendingApproval: ApprovalRequestSourceRecord = {
  draft_package_id: "draft-1",
  lineage_id: "lineage-1",
  project_id: "hq",
  conversation_id: "conversation-1",
  current_interpretation: "Current interpretation",
  proposed_work: "Proposed work",
  proposed_artifacts: null,
  in_scope: "In scope",
  out_of_scope: null,
  constraints: "Constraint",
  expected_outcome: "Expected outcome",
  unresolved_questions: null,
  evidence_entry_ids: '["iel-1"]',
  source_draft_status: "draft",
  created_at: "2026-09-16T20:00:00.000Z",
  updated_at: "2026-09-16T20:01:00.000Z",
};

test(
  "Living Draft remains explicitly non-authoritative",
  () => {
    const result =
      adaptLivingDraftForAtlas(livingDraft, "hq");

    assert.equal(result.observationKind, "living_draft");
    assert.equal(
      result.authorityStatus,
      "non_authoritative",
    );
    assert.equal(result.projectId, "hq");
    assert.equal(
      result.conversationId,
      "conversation-1",
    );
    assert.equal(result.lineageId, "lineage-1");
  },
);

test(
  "Pending Approval remains a pending authority transition",
  () => {
    const result =
      adaptPendingApprovalForAtlas(
        pendingApproval,
        "hq",
      );

    assert.equal(
      result.observationKind,
      "pending_approval_request",
    );
    assert.equal(
      result.authorityStatus,
      "pending_transition",
    );
    assert.equal(result.projectId, "hq");
    assert.equal(
      result.conversationId,
      "conversation-1",
    );
    assert.equal(result.lineageId, "lineage-1");
  },
);

test(
  "Living Draft adapter fails closed across project scope",
  () => {
    assert.throws(
      () =>
        adaptLivingDraftForAtlas(
          livingDraft,
          "other-project",
        ),
      /violated project scope/,
    );
  },
);

test(
  "Pending Approval adapter fails closed across project scope",
  () => {
    assert.throws(
      () =>
        adaptPendingApprovalForAtlas(
          pendingApproval,
          "other-project",
        ),
      /violated project scope/,
    );
  },
);
