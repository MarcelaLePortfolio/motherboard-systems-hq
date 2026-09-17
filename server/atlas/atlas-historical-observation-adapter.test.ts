import assert from "node:assert/strict";
import test from "node:test";

import {
  adaptAtlasHistoricalObservation,
} from "./atlas-historical-observation-adapter";
import type {
  AtlasHistoricalObservationRecord,
} from "../../db/atlas-historical-observation-persistence";

const base = {
  observationId: 1,
  projectId: "hq",
  conversationId: "conversation-1",
  lineageId: "lineage-1",
  persistedAt: "2026-09-17T20:00:01.000Z",
};

test("adapts historical IEL snapshot into existing Atlas observation contract", () => {
  const record: AtlasHistoricalObservationRecord = {
    ...base,
    sourceKind: "interpretation_evidence",
    sourceIdentity: "iel-1",
    observedAt: "2026-09-17T20:00:00.000Z",
    authorityStatus:
      "matilda_authored_interpretive_evidence",
    payload: {
      entryId: "iel-1",
      projectId: "hq",
      conversationId: "conversation-1",
      createdAt: "2026-09-17T20:00:00.000Z",
      actor: "matilda",
      interpretationEvent: "interpreted",
      minimumSufficientContext: "context",
      supportingRawEvidence: "evidence",
      matildaObservation: "observation",
      unresolvedQuestions: null,
      lineageReferences: "lineage",
      investigationLifecycle: null,
      packageSemantics: null,
      supersessionStatus: "current",
    },
  };

  const adapted =
    adaptAtlasHistoricalObservation(record);

  assert.equal(
    adapted.observationKind,
    "interpretation_evidence",
  );

  if (
    adapted.observationKind !==
    "interpretation_evidence"
  ) {
    assert.fail("unexpected observation kind");
  }

  assert.equal(adapted.observation.entryId, "iel-1");
  assert.equal(
    adapted.observation.minimumSufficientContext,
    "context",
  );
});

test("fails closed on historical IEL scope mismatch", () => {
  const record: AtlasHistoricalObservationRecord = {
    ...base,
    sourceKind: "interpretation_evidence",
    sourceIdentity: "iel-1",
    observedAt: "2026-09-17T20:00:00.000Z",
    authorityStatus:
      "matilda_authored_interpretive_evidence",
    payload: {
      entryId: "iel-1",
      projectId: "other-project",
      conversationId: "conversation-1",
      createdAt: "2026-09-17T20:00:00.000Z",
      actor: "matilda",
      interpretationEvent: "interpreted",
      minimumSufficientContext: "context",
      supportingRawEvidence: "evidence",
      matildaObservation: "observation",
      unresolvedQuestions: null,
      lineageReferences: null,
      investigationLifecycle: null,
      packageSemantics: null,
      supersessionStatus: "current",
    },
  };

  assert.throws(
    () => adaptAtlasHistoricalObservation(record),
    /violated persisted scope/,
  );
});

test("normalizes historical Living Draft without authority promotion", () => {
  const record: AtlasHistoricalObservationRecord = {
    ...base,
    sourceKind: "living_draft",
    sourceIdentity: "draft-1",
    observedAt: "2026-09-17T20:01:00.000Z",
    authorityStatus: "non_authoritative",
    payload: {
      draft_package_id: "draft-1",
      lineage_id: "lineage-1",
      project_id: "hq",
      conversation_id: "conversation-1",
      current_interpretation: "interpretation",
      proposed_work: null,
      proposed_artifacts: null,
      in_scope: null,
      out_of_scope: null,
      constraints: null,
      expected_outcome: null,
      unresolved_questions: null,
      evidence_entry_ids: "iel-1",
      status: "living",
      created_at: "2026-09-17T20:00:00.000Z",
      updated_at: "2026-09-17T20:01:00.000Z",
    },
  };

  const adapted =
    adaptAtlasHistoricalObservation(record);

  assert.equal(adapted.observationKind, "living_draft");

  if (adapted.observationKind !== "living_draft") {
    assert.fail("unexpected observation kind");
  }

  assert.equal(
    adapted.authorityStatus,
    "non_authoritative",
  );
  assert.equal(
    adapted.observation.authorityStatus,
    "non_authoritative",
  );
});

test("fails closed instead of promoting Living Draft authority", () => {
  const record: AtlasHistoricalObservationRecord = {
    ...base,
    sourceKind: "living_draft",
    sourceIdentity: "draft-1",
    observedAt: "2026-09-17T20:01:00.000Z",
    authorityStatus: "approved",
    payload: {
      draft_package_id: "draft-1",
      lineage_id: "lineage-1",
      project_id: "hq",
      conversation_id: "conversation-1",
      current_interpretation: "interpretation",
      proposed_work: null,
      proposed_artifacts: null,
      in_scope: null,
      out_of_scope: null,
      constraints: null,
      expected_outcome: null,
      unresolved_questions: null,
      evidence_entry_ids: "iel-1",
      status: "living",
      created_at: "2026-09-17T20:00:00.000Z",
      updated_at: "2026-09-17T20:01:00.000Z",
    },
  };

  assert.throws(
    () => adaptAtlasHistoricalObservation(record),
    /must remain non_authoritative/,
  );
});
