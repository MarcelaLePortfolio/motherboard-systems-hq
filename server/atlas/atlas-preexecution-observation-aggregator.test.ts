import assert from "node:assert/strict";
import test from "node:test";

import {
  aggregateAtlasPreExecutionObservationRecords,
} from "./atlas-preexecution-observation-aggregator";

test("aggregator preserves distinct source and authority states", () => {
  const result = aggregateAtlasPreExecutionObservationRecords("hq", {
    interpretationEvidence: [{
      entryId: "iel-1",
      projectId: "hq",
      conversationId: "conversation-1",
      lineageId: "lineage-1",
      createdAt: "2026-09-16T20:00:00.000Z",
    } as any],
    livingDrafts: [{
      draftPackageId: "draft-1",
      lineageId: "lineage-1",
      projectId: "hq",
      conversationId: "conversation-1",
      updatedAt: "2026-09-16T20:01:00.000Z",
    } as any],
    pendingApprovals: [{
      draftPackageId: "draft-1",
      lineageId: "lineage-1",
      projectId: "hq",
      conversationId: "conversation-1",
      updatedAt: "2026-09-16T20:02:00.000Z",
    } as any],
    canonicalPackages: [{
      observationType: "canonical_package",
      authority: "authoritative",
      status: "canonical_approved",
      projectId: "hq",
      conversationId: "conversation-1",
      packageId: "pkg-1",
      packageVersion: 1,
      draftRevisionId: "revision-1",
      lineageId: "lineage-1",
      approvalActor: "marcela",
      approvalTimestamp: "2026-09-16T20:03:00.000Z",
    }],
  });

  assert.deepEqual(
    result.map(({ sourceKind, authorityStatus }) => [
      sourceKind,
      authorityStatus,
    ]),
    [
      ["interpretation_evidence", "matilda_authored_interpretive_evidence"],
      ["living_draft", "non_authoritative"],
      ["pending_approval_request", "pending_transition"],
      ["canonical_package", "authoritative"],
    ],
  );
});

test("aggregator provides deterministic chronology", () => {
  const result = aggregateAtlasPreExecutionObservationRecords("hq", {
    interpretationEvidence: [],
    livingDrafts: [{
      draftPackageId: "draft-z",
      lineageId: "lineage-z",
      projectId: "hq",
      conversationId: "conversation-z",
      updatedAt: "2026-09-16T20:00:00.000Z",
    } as any],
    pendingApprovals: [],
    canonicalPackages: [{
      observationType: "canonical_package",
      authority: "authoritative",
      status: "canonical_approved",
      projectId: "hq",
      conversationId: "conversation-a",
      packageId: "pkg-a",
      packageVersion: 1,
      draftRevisionId: "revision-a",
      lineageId: "lineage-a",
      approvalActor: "marcela",
      approvalTimestamp: "2026-09-16T20:00:00.000Z",
    }],
  });

  assert.deepEqual(
    result.map(({ sourceKind }) => sourceKind),
    ["canonical_package", "living_draft"],
  );
});

test("aggregator fails closed across project scope", () => {
  assert.throws(
    () => aggregateAtlasPreExecutionObservationRecords("hq", {
      interpretationEvidence: [],
      livingDrafts: [{
        draftPackageId: "draft-other",
        lineageId: "lineage-other",
        projectId: "other-project",
        conversationId: "conversation-other",
        updatedAt: "2026-09-16T20:00:00.000Z",
      } as any],
      pendingApprovals: [],
      canonicalPackages: [],
    }),
    /violated project scope/,
  );
});

test("aggregator requires explicit project scope", () => {
  assert.throws(
    () => aggregateAtlasPreExecutionObservationRecords("   ", {
      interpretationEvidence: [],
      livingDrafts: [],
      pendingApprovals: [],
      canonicalPackages: [],
    }),
    /projectId is required/,
  );
});
