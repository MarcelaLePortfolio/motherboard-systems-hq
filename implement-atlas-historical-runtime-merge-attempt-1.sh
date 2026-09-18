#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d4f72a0d2"

AGGREGATOR="server/atlas/atlas-preexecution-observation-aggregator.ts"
AGGREGATOR_TEST="server/atlas/atlas-preexecution-observation-aggregator.test.ts"
ADAPTER="server/atlas/atlas-historical-observation-adapter.ts"
PERSISTENCE="db/atlas-historical-observation-persistence.ts"
ROUTE="server/routes/atlas/preexecution.ts"
REASONER="server/atlas/atlas-preexecution-structural-reasoner.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

test -z "$(
  git diff --name-only -- \
    "$AGGREGATOR" \
    "$AGGREGATOR_TEST" \
    "$ADAPTER" \
    "$PERSISTENCE" \
    "$ROUTE" \
    "$REASONER"
)"

python3 - <<'PY'
from pathlib import Path

path = Path("db/atlas-historical-observation-persistence.ts")
text = path.read_text()

old = '''export function readAtlasHistoricalObservations(
  projectId: string,
  db?: any,
): AtlasHistoricalObservationRecord[] {
  const sqlite = db ?? new Database("db/main.db");
  const ownsConnection = db === undefined;
'''

new = '''export function readAtlasHistoricalObservations(
  projectId: string,
  databasePath = "db/main.db",
  db?: any,
): AtlasHistoricalObservationRecord[] {
  const sqlite = db ?? new Database(databasePath);
  const ownsConnection = db === undefined;
'''

if text.count(old) != 1:
    raise SystemExit("FAIL CLOSED: historical persistence read seam mismatch")

path.write_text(text.replace(old, new, 1))
PY

python3 - <<'PY'
from pathlib import Path

path = Path("server/atlas/atlas-historical-observation-adapter.ts")
text = path.read_text()

old = '''export function readAtlasHistoricalTypedObservations(
  projectId: string,
): AtlasHistoricalTypedObservation[] {
  return readAtlasHistoricalObservations(projectId).map(
    adaptAtlasHistoricalObservation,
  );
}
'''

new = '''export function readAtlasHistoricalTypedObservations(
  projectId: string,
  databasePath = "db/main.db",
): AtlasHistoricalTypedObservation[] {
  return readAtlasHistoricalObservations(
    projectId,
    databasePath,
  ).map(
    adaptAtlasHistoricalObservation,
  );
}
'''

if text.count(old) != 1:
    raise SystemExit("FAIL CLOSED: historical adapter read seam mismatch")

path.write_text(text.replace(old, new, 1))
PY

python3 - <<'PY'
from pathlib import Path

path = Path("server/atlas/atlas-preexecution-observation-aggregator.ts")
text = path.read_text()

anchor = '''import {
  readAtlasCanonicalPackageObservations,
  type AtlasCanonicalPackageObservation,
} from "./atlas-canonical-package-observation";
'''

replacement = anchor + '''import {
  readAtlasHistoricalTypedObservations,
} from "./atlas-historical-observation-adapter";
'''

if 'readAtlasHistoricalTypedObservations' not in text:
    if text.count(anchor) != 1:
        raise SystemExit("FAIL CLOSED: aggregator import seam mismatch")
    text = text.replace(anchor, replacement, 1)

old = '''  return aggregateAtlasPreExecutionObservationRecords(
    normalizedProjectId,
    {
      interpretationEvidence: readAtlasPreExecutionObservations({
        projectId: normalizedProjectId,
        conversationId: normalizedConversationId,
      }),
      livingDrafts: readAtlasLivingDraftObservations(
        normalizedProjectId,
        databasePath,
      ).filter(
        (observation) =>
          observation.conversationId === normalizedConversationId,
      ),
      pendingApprovals: readAtlasPendingApprovalObservations(
        normalizedProjectId,
        databasePath,
      ).filter(
        (observation) =>
          observation.conversationId === normalizedConversationId,
      ),
      canonicalPackages: readAtlasCanonicalPackageObservations(
        normalizedProjectId,
        databasePath,
      ).filter(
        (observation) =>
          observation.conversationId === normalizedConversationId,
      ),
    },
  );
'''

new = '''  const liveObservations =
    aggregateAtlasPreExecutionObservationRecords(
      normalizedProjectId,
      {
        interpretationEvidence: readAtlasPreExecutionObservations({
          projectId: normalizedProjectId,
          conversationId: normalizedConversationId,
        }),
        livingDrafts: readAtlasLivingDraftObservations(
          normalizedProjectId,
          databasePath,
        ).filter(
          (observation) =>
            observation.conversationId === normalizedConversationId,
        ),
        pendingApprovals: readAtlasPendingApprovalObservations(
          normalizedProjectId,
          databasePath,
        ).filter(
          (observation) =>
            observation.conversationId === normalizedConversationId,
        ),
        canonicalPackages: readAtlasCanonicalPackageObservations(
          normalizedProjectId,
          databasePath,
        ).filter(
          (observation) =>
            observation.conversationId === normalizedConversationId,
        ),
      },
    );

  const historicalObservations =
    readAtlasHistoricalTypedObservations(
      normalizedProjectId,
      databasePath,
    ).filter(
      (historical) =>
        historical.observation.conversationId ===
        normalizedConversationId,
    );

  const liveInterpretationEntryIds = new Set(
    liveObservations
      .filter(
        (observation) =>
          observation.sourceKind === "interpretation_evidence",
      )
      .map(
        (observation) =>
          observation.payload.entryId,
      ),
  );

  const liveDraftRevisionKeys = new Set(
    liveObservations
      .filter(
        (observation) =>
          observation.sourceKind === "living_draft",
      )
      .map(
        (observation) =>
          `${observation.payload.draftPackageId}\\u0000${observation.payload.updatedAt}`,
      ),
  );

  const historicalTypedObservations =
    historicalObservations
      .filter((historical) => {
        if (
          historical.observationKind ===
          "interpretation_evidence"
        ) {
          return !liveInterpretationEntryIds.has(
            historical.observation.entryId,
          );
        }

        return !liveDraftRevisionKeys.has(
          `${historical.observation.draftPackageId}\\u0000${historical.observation.updatedAt}`,
        );
      })
      .map(
        (historical): AtlasTypedPreexecutionObservation => {
          if (
            historical.observationKind ===
            "interpretation_evidence"
          ) {
            return {
              sourceKind: "interpretation_evidence",
              authorityStatus:
                historical.authorityStatus,
              projectId:
                historical.observation.projectId,
              conversationId:
                historical.observation.conversationId,
              lineageId:
                historical.observation.lineageReferences ?? null,
              observedAt:
                historical.observation.createdAt,
              payload:
                historical.observation,
            };
          }

          return {
            sourceKind: "living_draft",
            authorityStatus: "non_authoritative",
            projectId:
              historical.observation.projectId,
            conversationId:
              historical.observation.conversationId,
            lineageId:
              historical.observation.lineageId,
            observedAt:
              historical.observation.updatedAt,
            payload:
              historical.observation,
          };
        },
      );

  return [
    ...liveObservations,
    ...historicalTypedObservations,
  ].sort(compareObservations);
'''

if text.count(old) != 1:
    raise SystemExit("FAIL CLOSED: active typed-reader seam mismatch")

path.write_text(text.replace(old, new, 1))
PY

git diff --check -- \
  "$AGGREGATOR" \
  "$ADAPTER" \
  "$PERSISTENCE"

npx tsc --noEmit
npx tsx --test "$AGGREGATOR_TEST"
npx tsx --test server/atlas/atlas-historical-observation-adapter.test.ts
npx tsx --test db/atlas-historical-observation-persistence.test.ts
npx tsx --test server/routes/atlas/preexecution.test.ts

git diff --exit-code -- "$ROUTE" "$REASONER"
test -z "$(git diff --cached --name-only)"

printf '\n=== ATTEMPT 1 RESULT ===\n'
echo "ATLAS_HISTORICAL_RUNTIME_MERGE=VALIDATED_LOCAL_ONLY"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=0"
echo "ROUTE_CHANGED=NO"
echo "STRUCTURAL_REASONER_CHANGED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "SAFE_TO_STOP_HERE=YES"
echo "NEXT_GATE=PRODUCT_COMMIT_AND_PUSH_AUTHORIZATION"
echo "NO PRODUCT COMMIT / NO PRODUCT PUSH"

printf '\n=== PRODUCT STATUS ===\n'
git status --short -- \
  "$AGGREGATOR" \
  "$ADAPTER" \
  "$PERSISTENCE"
