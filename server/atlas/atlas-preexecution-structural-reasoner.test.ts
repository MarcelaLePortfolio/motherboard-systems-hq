import assert from "node:assert/strict";
import test from "node:test";

import {
  reasonOverAtlasPreExecutionObservations,
} from "./atlas-preexecution-structural-reasoner";

import type {
  AtlasTypedPreexecutionObservation,
} from "./atlas-preexecution-observation-aggregator";

function fixtureObservations():
  AtlasTypedPreexecutionObservation[] {
  return [
    {
      sourceKind: "canonical_package",
      authorityStatus: "authoritative",
      projectId: "hq",
      conversationId: "conversation-1",
      lineageId: "lineage-1",
      observedAt: "2026-09-16T20:03:00.000Z",
      payload: {
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
        approvalTimestamp:
          "2026-09-16T20:03:00.000Z",
      },
    },
    {
      sourceKind: "living_draft",
      authorityStatus: "non_authoritative",
      projectId: "hq",
      conversationId: "conversation-1",
      lineageId: "lineage-1",
      observedAt: "2026-09-16T20:01:00.000Z",
      payload: {
        observationKind: "living_draft",
        authorityStatus: "non_authoritative",
        draftPackageId: "draft-1",
        lineageId: "lineage-1",
        projectId: "hq",
        conversationId: "conversation-1",
        currentInterpretation: "draft interpretation",
        proposedWork: null,
        proposedArtifacts: null,
        inScope: null,
        outOfScope: null,
        constraints: null,
        expectedOutcome: null,
        unresolvedQuestions: null,
        evidenceEntryIds: "[]",
        sourceStatus: "living_draft",
        createdAt: "2026-09-16T20:00:00.000Z",
        updatedAt: "2026-09-16T20:01:00.000Z",
      },
    },
    {
      sourceKind: "pending_approval_request",
      authorityStatus: "pending_transition",
      projectId: "hq",
      conversationId: "conversation-1",
      lineageId: "lineage-1",
      observedAt: "2026-09-16T20:02:00.000Z",
      payload: {
        observationKind: "pending_approval_request",
        authorityStatus: "pending_transition",
        draftPackageId: "draft-1",
        lineageId: "lineage-1",
        projectId: "hq",
        conversationId: "conversation-1",
        currentInterpretation: "draft interpretation",
        proposedWork: null,
        proposedArtifacts: null,
        inScope: null,
        outOfScope: null,
        constraints: null,
        expectedOutcome: null,
        unresolvedQuestions: null,
        evidenceEntryIds: "[]",
        sourceDraftStatus: "pending_approval",
        createdAt: "2026-09-16T20:00:00.000Z",
        updatedAt: "2026-09-16T20:02:00.000Z",
      },
    },
  ];
}

test(
  "structural reasoner preserves chronology and authority sequence",
  () => {
    const result =
      reasonOverAtlasPreExecutionObservations(
        "hq",
        fixtureObservations(),
      );

    assert.deepEqual(
      result.lineageSequences,
      [
        {
          lineageId: "lineage-1",
          conversationIds: ["conversation-1"],
          observationIds: [
            "draft-1",
            "draft-1",
            "pkg-1:1",
          ],
          sourceSequence: [
            "living_draft",
            "pending_approval_request",
            "canonical_package",
          ],
          authoritySequence: [
            "non_authoritative",
            "pending_transition",
            "authoritative",
          ],
        },
      ],
    );
  },
);

test(
  "structural reasoner does not invent lineage for observations without lineage",
  () => {
    const observations:
      AtlasTypedPreexecutionObservation[] = [
      {
        sourceKind: "interpretation_evidence",
        authorityStatus:
          "matilda_authored_interpretive_evidence",
        projectId: "hq",
        conversationId: "conversation-2",
        lineageId: null,
        observedAt: "2026-09-16T20:00:00.000Z",
        payload: {
          entryId: "iel-1",
          createdAt: "2026-09-16T20:00:00.000Z",
          actor: "matilda",
          projectId: "hq",
          conversationId: "conversation-2",
          interpretationEvent: "interpreted",
          minimumSufficientContext: "context",
          supportingRawEvidence: "evidence",
          matildaObservation: "observation",
          unresolvedQuestions: null,
          lineageReferences: null,
          investigationLifecycle: null,
          packageSemantics: null,
          supersessionStatus: "active",
        },
      },
    ];

    const result =
      reasonOverAtlasPreExecutionObservations(
        "hq",
        observations,
      );

    assert.equal(result.observations.length, 1);
    assert.deepEqual(result.lineageSequences, []);
  },
);

test(
  "structural reasoner fails closed across project scope",
  () => {
    const observations = fixtureObservations();

    observations[0] = {
      ...observations[0],
      projectId: "other-project",
    };

    assert.throws(
      () =>
        reasonOverAtlasPreExecutionObservations(
          "hq",
          observations,
        ),
      /violated project scope/,
    );
  },
);

test(
  "structural reasoner requires explicit project scope",
  () => {
    assert.throws(
      () =>
        reasonOverAtlasPreExecutionObservations(
          "   ",
          [],
        ),
      /projectId is required/,
    );
  },
);
