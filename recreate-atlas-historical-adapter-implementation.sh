#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="052f35e5b"
IMPL_SCRIPT="implement-atlas-historical-observation-adapter-attempt-1.sh"

printf '\n=== VERIFY BASELINE ===\n'
git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

printf '\n=== RECREATE ALREADY-AUTHORIZED IMPLEMENTATION SCRIPT ===\n'
cat > "$IMPL_SCRIPT" << 'SCRIPT'
#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

WORKFLOW="server/matilda-chat-workflow.ts"
ADAPTER="server/atlas/atlas-historical-observation-adapter.ts"
TEST="server/atlas/atlas-historical-observation-adapter.test.ts"

test ! -e "$ADAPTER"
test ! -e "$TEST"

python3 - <<'PY'
from pathlib import Path

path = Path("server/matilda-chat-workflow.ts")
text = path.read_text()

old = '''        actor: result.agent,
        matildaObservation:
          durableInterpretation,
        supportProvenance,
        investigationLifecycle:
          ollamaResult.investigationLifecycle,
        packageSemantics:
          ollamaResult.packageSemantics,
'''

new = '''        actor: result.agent,
        interpretationEvent:
          "Matilda interpreted the current project-scoped conversation turn using available conversation history and bounded project evidence.",
        minimumSufficientContext: [
          `project:${projectId}`,
          `conversation:${conversationId}`,
          `prior_turns:${history.length}`,
          `project_context_excerpts:${projectContextRetrieval.excerpts.length}`,
          projectContextRetrieval.warning
            ? "project_context_warning:present"
            : "project_context_warning:none",
        ].join("; "),
        supportingRawEvidence: clampText(
          JSON.stringify({
            user_message: message,
            prior_turn_count: history.length,
            project_context_sources:
              projectContextRetrieval.excerpts.map(
                (excerpt) => ({
                  relative_path: excerpt.relativePath,
                  line_number: excerpt.lineNumber,
                  provenance: excerpt.provenance,
                  authority_status: excerpt.authorityStatus,
                }),
              ),
            project_context_warning:
              projectContextRetrieval.warning,
            support_source_references:
              supportProvenance.supportSourceReferences,
            evidence_sufficient:
              supportProvenance.evidenceSufficient,
          }),
          12000,
        ),
        matildaObservation:
          durableInterpretation,
        unresolvedQuestions: null,
        lineageReferences: [
          `project:${projectId}`,
          `conversation:${conversationId}`,
          `interpretation_entry:${result.meta.interpretation_entry_id}`,
        ].join("; "),
        investigationLifecycle:
          ollamaResult.investigationLifecycle,
        packageSemantics:
          ollamaResult.packageSemantics,
        supersessionStatus: "current",
        supportProvenance,
'''

if text.count(old) != 1:
    raise SystemExit(
        f"FAIL CLOSED: expected one IEL historical payload seam; found {text.count(old)}"
    )

path.write_text(text.replace(old, new, 1))
PY

cat > "$ADAPTER" <<'TS'
import {
  readAtlasHistoricalObservations,
  type AtlasHistoricalObservationRecord,
} from "../../db/atlas-historical-observation-persistence";
import type { AtlasPreExecutionObservation } from "./atlas-preexecution-read-model";
import type { AtlasLivingDraftObservation } from "./atlas-draft-approval-observation";

export type AtlasHistoricalTypedObservation =
  | {
      observationKind: "interpretation_evidence";
      authorityStatus: "matilda_authored_interpretive_evidence";
      sourceIdentity: string;
      observedAt: string;
      observation: AtlasPreExecutionObservation;
    }
  | {
      observationKind: "living_draft";
      authorityStatus: "non_authoritative";
      sourceIdentity: string;
      observedAt: string;
      observation: AtlasLivingDraftObservation;
    };

function requireObject(
  value: unknown,
  source: string,
): Record<string, unknown> {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new Error(
      `Atlas historical ${source} payload must be an object.`,
    );
  }

  return value as Record<string, unknown>;
}

function requireString(
  value: unknown,
  field: string,
): string {
  if (typeof value !== "string" || value.length === 0) {
    throw new Error(
      `Atlas historical observation requires ${field}.`,
    );
  }

  return value;
}

function nullableString(
  value: unknown,
  field: string,
): string | null {
  if (value === null) return null;

  if (typeof value !== "string") {
    throw new Error(
      `Atlas historical observation requires nullable ${field}.`,
    );
  }

  return value;
}

function requireMatchingScope(
  record: AtlasHistoricalObservationRecord,
  projectId: unknown,
  conversationId: unknown,
): void {
  if (
    projectId !== record.projectId ||
    conversationId !== record.conversationId
  ) {
    throw new Error(
      "Atlas historical observation payload violated persisted scope.",
    );
  }
}

function adaptHistoricalInterpretationEvidence(
  record: AtlasHistoricalObservationRecord,
): AtlasHistoricalTypedObservation {
  if (
    record.authorityStatus !==
    "matilda_authored_interpretive_evidence"
  ) {
    throw new Error(
      "Atlas historical interpretation evidence authority status is invalid.",
    );
  }

  const payload = requireObject(
    record.payload,
    "interpretation evidence",
  );

  requireMatchingScope(
    record,
    payload.projectId,
    payload.conversationId,
  );

  return {
    observationKind: "interpretation_evidence",
    authorityStatus:
      "matilda_authored_interpretive_evidence",
    sourceIdentity: record.sourceIdentity,
    observedAt: record.observedAt,
    observation: {
      entryId: requireString(payload.entryId, "entryId"),
      createdAt: requireString(
        payload.createdAt,
        "createdAt",
      ),
      actor: requireString(payload.actor, "actor"),
      projectId: record.projectId,
      conversationId: record.conversationId,
      interpretationEvent: requireString(
        payload.interpretationEvent,
        "interpretationEvent",
      ),
      minimumSufficientContext: requireString(
        payload.minimumSufficientContext,
        "minimumSufficientContext",
      ),
      supportingRawEvidence: requireString(
        payload.supportingRawEvidence,
        "supportingRawEvidence",
      ),
      matildaObservation: requireString(
        payload.matildaObservation,
        "matildaObservation",
      ),
      unresolvedQuestions: nullableString(
        payload.unresolvedQuestions,
        "unresolvedQuestions",
      ),
      lineageReferences: nullableString(
        payload.lineageReferences,
        "lineageReferences",
      ),
      investigationLifecycle:
        payload.investigationLifecycle as AtlasPreExecutionObservation["investigationLifecycle"],
      packageSemantics:
        payload.packageSemantics as AtlasPreExecutionObservation["packageSemantics"],
      supersessionStatus: requireString(
        payload.supersessionStatus,
        "supersessionStatus",
      ),
    },
  };
}

function adaptHistoricalLivingDraft(
  record: AtlasHistoricalObservationRecord,
): AtlasHistoricalTypedObservation {
  if (record.authorityStatus !== "non_authoritative") {
    throw new Error(
      "Atlas historical Living Draft authority status must remain non_authoritative.",
    );
  }

  const payload = requireObject(
    record.payload,
    "Living Draft",
  );

  const projectId = requireString(
    payload.project_id,
    "project_id",
  );
  const conversationId = nullableString(
    payload.conversation_id,
    "conversation_id",
  );

  requireMatchingScope(
    record,
    projectId,
    conversationId,
  );

  return {
    observationKind: "living_draft",
    authorityStatus: "non_authoritative",
    sourceIdentity: record.sourceIdentity,
    observedAt: record.observedAt,
    observation: {
      observationKind: "living_draft",
      authorityStatus: "non_authoritative",
      draftPackageId: requireString(
        payload.draft_package_id,
        "draft_package_id",
      ),
      lineageId: requireString(
        payload.lineage_id,
        "lineage_id",
      ),
      projectId,
      conversationId,
      currentInterpretation: requireString(
        payload.current_interpretation,
        "current_interpretation",
      ),
      proposedWork: nullableString(
        payload.proposed_work,
        "proposed_work",
      ),
      proposedArtifacts: nullableString(
        payload.proposed_artifacts,
        "proposed_artifacts",
      ),
      inScope: nullableString(
        payload.in_scope,
        "in_scope",
      ),
      outOfScope: nullableString(
        payload.out_of_scope,
        "out_of_scope",
      ),
      constraints: nullableString(
        payload.constraints,
        "constraints",
      ),
      expectedOutcome: nullableString(
        payload.expected_outcome,
        "expected_outcome",
      ),
      unresolvedQuestions: nullableString(
        payload.unresolved_questions,
        "unresolved_questions",
      ),
      evidenceEntryIds: requireString(
        payload.evidence_entry_ids,
        "evidence_entry_ids",
      ),
      sourceStatus: requireString(
        payload.status,
        "status",
      ),
      createdAt: requireString(
        payload.created_at,
        "created_at",
      ),
      updatedAt: requireString(
        payload.updated_at,
        "updated_at",
      ),
    },
  };
}

export function adaptAtlasHistoricalObservation(
  record: AtlasHistoricalObservationRecord,
): AtlasHistoricalTypedObservation {
  switch (record.sourceKind) {
    case "interpretation_evidence":
      return adaptHistoricalInterpretationEvidence(record);
    case "living_draft":
      return adaptHistoricalLivingDraft(record);
  }
}

export function readAtlasHistoricalTypedObservations(
  projectId: string,
): AtlasHistoricalTypedObservation[] {
  return readAtlasHistoricalObservations(projectId).map(
    adaptAtlasHistoricalObservation,
  );
}
TS

cat > "$TEST" <<'TS'
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
TS

printf '\n=== VALIDATE AUTHORIZED IMPLEMENTATION ===\n'
git diff --check -- "$WORKFLOW" "$ADAPTER" "$TEST"
npx tsc --noEmit
npx tsx --test "$TEST"
npx tsx --test db/atlas-historical-observation-persistence.test.ts
npx tsx --test \
  server/matilda-chat-workflow.package-semantics-policy.test.ts \
  server/matilda-chat-workflow.explicit-target.integration.test.ts

printf '\n=== VERIFY PROTECTED ATLAS FILES UNCHANGED ===\n'
git diff --exit-code -- \
  server/atlas/atlas-preexecution-read-model.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts

test -z "$(git diff --cached --name-only)"

printf '\n=== RESULT ===\n'
echo "AUTHORIZED_IMPLEMENTATION_EXECUTED=YES"
echo "PRODUCT_CHANGES=LOCAL_VALIDATED_NOT_COMMITTED"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_GATE=COMMIT_AND_PUSH_AUTHORIZATION"
SCRIPT

chmod +x "$IMPL_SCRIPT"
./"$IMPL_SCRIPT"

printf '\n=== PRODUCT STATUS ===\n'
git status --short -- \
  server/matilda-chat-workflow.ts \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-historical-observation-adapter.test.ts

printf '\n=== STOP — NO PRODUCT COMMIT / NO PRODUCT PUSH ===\n'
