#!/bin/bash
set -euo pipefail

EXPECTED_BRANCH="feature/support-source-references-runtime"
ALLOWED_EXISTING_TRACKED_DRIFT=(
  ".DS_Store"
  "scripts/diagnose-live-selected-context-identities.ts"
  "scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts"
  "scripts/utils/ollamaChat.structured-evidence-object.test.ts"
  "scripts/utils/ollamaChat.ts"
)

echo "=== ATLAS HISTORICAL PERSISTENCE — ATTEMPT 1 ==="
echo "Scope: persistence primitive + tests only"
echo "No workflow hook"
echo "No Atlas GET mutation"
echo "No execution authority"
echo "No source foreign keys"

test "$(git rev-parse --abbrev-ref HEAD)" = "$EXPECTED_BRANCH"
git fetch origin "$EXPECTED_BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$EXPECTED_BRANCH")" = $'0\t0'
test -z "$(git diff --cached --name-only)"

mapfile_safe() {
  while IFS= read -r line; do
    [ -n "$line" ] && printf '%s\n' "$line"
  done
}

unexpected="$(
  git diff --name-only |
  while IFS= read -r path; do
    allowed=0
    for existing in "${ALLOWED_EXISTING_TRACKED_DRIFT[@]}"; do
      if [ "$path" = "$existing" ]; then
        allowed=1
        break
      fi
    done
    [ "$allowed" -eq 1 ] || printf '%s\n' "$path"
  done
)"

if [ -n "$unexpected" ]; then
  echo "FAIL CLOSED: unexpected pre-existing tracked drift:"
  printf '%s\n' "$unexpected"
  exit 1
fi

cat > db/atlas-historical-observation-persistence.ts <<'TS'
import Database from "better-sqlite3";

export type AtlasHistoricalObservationSourceKind =
  | "interpretation_evidence"
  | "living_draft";

export interface PersistAtlasHistoricalObservationInput {
  sourceKind: AtlasHistoricalObservationSourceKind;
  sourceIdentity: string;
  projectId: string;
  conversationId: string;
  lineageId: string | null;
  observedAt: string;
  authorityStatus: string;
  payload: unknown;
  persistedAt?: string;
}

export interface AtlasHistoricalObservationRecord {
  observationId: number;
  sourceKind: AtlasHistoricalObservationSourceKind;
  sourceIdentity: string;
  projectId: string;
  conversationId: string;
  lineageId: string | null;
  observedAt: string;
  authorityStatus: string;
  payload: unknown;
  persistedAt: string;
}

type AtlasHistoricalObservationRow = {
  observation_id: number;
  source_kind: AtlasHistoricalObservationSourceKind;
  source_identity: string;
  project_id: string;
  conversation_id: string;
  lineage_id: string | null;
  observed_at: string;
  authority_status: string;
  payload_json: string;
  persisted_at: string;
};

function requireNonEmpty(value: string, field: string): string {
  const normalized = value.trim();
  if (!normalized) {
    throw new Error(`${field} is required`);
  }
  return normalized;
}

export function atlasInterpretationEvidenceSourceIdentity(
  entryId: string,
): string {
  return requireNonEmpty(entryId, "entryId");
}

export function atlasLivingDraftSourceIdentity(
  draftPackageId: string,
  updatedAt: string,
): string {
  return JSON.stringify([
    requireNonEmpty(draftPackageId, "draftPackageId"),
    requireNonEmpty(updatedAt, "updatedAt"),
  ]);
}

export function ensureAtlasHistoricalObservationTable(sqlite: any): void {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS atlas_historical_observations (
      observation_id INTEGER PRIMARY KEY AUTOINCREMENT,
      source_kind TEXT NOT NULL
        CHECK (source_kind IN ('interpretation_evidence', 'living_draft')),
      source_identity TEXT NOT NULL,
      project_id TEXT NOT NULL,
      conversation_id TEXT NOT NULL,
      lineage_id TEXT,
      observed_at TEXT NOT NULL,
      authority_status TEXT NOT NULL,
      payload_json TEXT NOT NULL,
      persisted_at TEXT NOT NULL,
      UNIQUE (source_kind, source_identity)
    );

    CREATE INDEX IF NOT EXISTS idx_atlas_historical_observations_project_time
      ON atlas_historical_observations (
        project_id,
        observed_at,
        observation_id
      );

    CREATE INDEX IF NOT EXISTS idx_atlas_historical_observations_conversation
      ON atlas_historical_observations (
        project_id,
        conversation_id,
        observed_at,
        observation_id
      );
  `);
}

function rowToRecord(
  row: AtlasHistoricalObservationRow,
): AtlasHistoricalObservationRecord {
  return {
    observationId: row.observation_id,
    sourceKind: row.source_kind,
    sourceIdentity: row.source_identity,
    projectId: row.project_id,
    conversationId: row.conversation_id,
    lineageId: row.lineage_id,
    observedAt: row.observed_at,
    authorityStatus: row.authority_status,
    payload: JSON.parse(row.payload_json),
    persistedAt: row.persisted_at,
  };
}

export function persistAtlasHistoricalObservation(
  input: PersistAtlasHistoricalObservationInput,
  db?: any,
): AtlasHistoricalObservationRecord {
  const sqlite = db ?? new Database("db/main.db");
  const ownsConnection = db === undefined;

  try {
    ensureAtlasHistoricalObservationTable(sqlite);

    const normalized = {
      sourceKind: input.sourceKind,
      sourceIdentity: requireNonEmpty(
        input.sourceIdentity,
        "sourceIdentity",
      ),
      projectId: requireNonEmpty(input.projectId, "projectId"),
      conversationId: requireNonEmpty(
        input.conversationId,
        "conversationId",
      ),
      lineageId: input.lineageId?.trim() || null,
      observedAt: requireNonEmpty(input.observedAt, "observedAt"),
      authorityStatus: requireNonEmpty(
        input.authorityStatus,
        "authorityStatus",
      ),
      payloadJson: JSON.stringify(input.payload),
      persistedAt:
        input.persistedAt?.trim() || new Date().toISOString(),
    };

    sqlite
      .prepare(`
        INSERT INTO atlas_historical_observations (
          source_kind,
          source_identity,
          project_id,
          conversation_id,
          lineage_id,
          observed_at,
          authority_status,
          payload_json,
          persisted_at
        ) VALUES (
          @sourceKind,
          @sourceIdentity,
          @projectId,
          @conversationId,
          @lineageId,
          @observedAt,
          @authorityStatus,
          @payloadJson,
          @persistedAt
        )
        ON CONFLICT(source_kind, source_identity) DO NOTHING
      `)
      .run(normalized);

    const row = sqlite
      .prepare(`
        SELECT
          observation_id,
          source_kind,
          source_identity,
          project_id,
          conversation_id,
          lineage_id,
          observed_at,
          authority_status,
          payload_json,
          persisted_at
        FROM atlas_historical_observations
        WHERE source_kind = ?
          AND source_identity = ?
      `)
      .get(
        normalized.sourceKind,
        normalized.sourceIdentity,
      ) as AtlasHistoricalObservationRow | undefined;

    if (!row) {
      throw new Error(
        "Atlas historical observation persistence failed closed",
      );
    }

    const existing = rowToRecord(row);

    if (
      existing.projectId !== normalized.projectId ||
      existing.conversationId !== normalized.conversationId ||
      existing.lineageId !== normalized.lineageId ||
      existing.observedAt !== normalized.observedAt ||
      existing.authorityStatus !== normalized.authorityStatus ||
      JSON.stringify(existing.payload) !== normalized.payloadJson
    ) {
      throw new Error(
        `Atlas source identity collision for ${normalized.sourceKind}:${normalized.sourceIdentity}`,
      );
    }

    return existing;
  } finally {
    if (ownsConnection) {
      sqlite.close();
    }
  }
}

export function readAtlasHistoricalObservations(
  projectId: string,
  db?: any,
): AtlasHistoricalObservationRecord[] {
  const sqlite = db ?? new Database("db/main.db");
  const ownsConnection = db === undefined;

  try {
    ensureAtlasHistoricalObservationTable(sqlite);

    const rows = sqlite
      .prepare(`
        SELECT
          observation_id,
          source_kind,
          source_identity,
          project_id,
          conversation_id,
          lineage_id,
          observed_at,
          authority_status,
          payload_json,
          persisted_at
        FROM atlas_historical_observations
        WHERE project_id = ?
        ORDER BY observed_at ASC, observation_id ASC
      `)
      .all(
        requireNonEmpty(projectId, "projectId"),
      ) as AtlasHistoricalObservationRow[];

    return rows.map(rowToRecord);
  } finally {
    if (ownsConnection) {
      sqlite.close();
    }
  }
}
TS

cat > db/atlas-historical-observation-persistence.test.ts <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import Database from "better-sqlite3";

import {
  atlasInterpretationEvidenceSourceIdentity,
  atlasLivingDraftSourceIdentity,
  ensureAtlasHistoricalObservationTable,
  persistAtlasHistoricalObservation,
  readAtlasHistoricalObservations,
} from "./atlas-historical-observation-persistence";

test("persists an immutable IEL observation without source foreign keys", () => {
  const sqlite = new Database(":memory:");

  const first = persistAtlasHistoricalObservation({
    sourceKind: "interpretation_evidence",
    sourceIdentity:
      atlasInterpretationEvidenceSourceIdentity("iel-1"),
    projectId: "hq",
    conversationId: "conversation-1",
    lineageId: "lineage-1",
    observedAt: "2026-09-16T20:00:00.000Z",
    authorityStatus: "matilda_authored_interpretive_evidence",
    payload: {
      entryId: "iel-1",
      matildaObservation: "durable observation",
    },
    persistedAt: "2026-09-17T00:00:00.000Z",
  }, sqlite);

  assert.equal(first.sourceIdentity, "iel-1");

  const foreignKeys = sqlite
    .prepare("PRAGMA foreign_key_list(atlas_historical_observations)")
    .all();

  assert.deepEqual(foreignKeys, []);

  sqlite.close();
});

test("Living Draft identity includes immutable source updated_at", () => {
  assert.equal(
    atlasLivingDraftSourceIdentity(
      "draft-1",
      "2026-09-16T20:01:00.000Z",
    ),
    '["draft-1","2026-09-16T20:01:00.000Z"]',
  );

  assert.notEqual(
    atlasLivingDraftSourceIdentity(
      "draft-1",
      "2026-09-16T20:01:00.000Z",
    ),
    atlasLivingDraftSourceIdentity(
      "draft-1",
      "2026-09-16T20:02:00.000Z",
    ),
  );
});

test("retry is idempotent for the same immutable observation", () => {
  const sqlite = new Database(":memory:");

  const input = {
    sourceKind: "living_draft" as const,
    sourceIdentity: atlasLivingDraftSourceIdentity(
      "draft-1",
      "2026-09-16T20:01:00.000Z",
    ),
    projectId: "hq",
    conversationId: "conversation-1",
    lineageId: "lineage-1",
    observedAt: "2026-09-16T20:01:00.000Z",
    authorityStatus: "non_authoritative",
    payload: {
      draftPackageId: "draft-1",
      updatedAt: "2026-09-16T20:01:00.000Z",
    },
    persistedAt: "2026-09-17T00:00:00.000Z",
  };

  const first =
    persistAtlasHistoricalObservation(input, sqlite);
  const second =
    persistAtlasHistoricalObservation(input, sqlite);

  assert.equal(first.observationId, second.observationId);

  const count = sqlite
    .prepare(`
      SELECT COUNT(*) AS count
      FROM atlas_historical_observations
    `)
    .get() as { count: number };

  assert.equal(count.count, 1);

  sqlite.close();
});

test("same source identity with changed payload fails closed", () => {
  const sqlite = new Database(":memory:");

  const base = {
    sourceKind: "interpretation_evidence" as const,
    sourceIdentity: "iel-1",
    projectId: "hq",
    conversationId: "conversation-1",
    lineageId: "lineage-1",
    observedAt: "2026-09-16T20:00:00.000Z",
    authorityStatus: "matilda_authored_interpretive_evidence",
    persistedAt: "2026-09-17T00:00:00.000Z",
  };

  persistAtlasHistoricalObservation({
    ...base,
    payload: { entryId: "iel-1", value: "original" },
  }, sqlite);

  assert.throws(
    () =>
      persistAtlasHistoricalObservation({
        ...base,
        payload: { entryId: "iel-1", value: "changed" },
      }, sqlite),
    /source identity collision/,
  );

  sqlite.close();
});

test("historical observations remain independently readable", () => {
  const sqlite = new Database(":memory:");
  ensureAtlasHistoricalObservationTable(sqlite);

  persistAtlasHistoricalObservation({
    sourceKind: "interpretation_evidence",
    sourceIdentity: "iel-1",
    projectId: "hq",
    conversationId: "conversation-1",
    lineageId: "lineage-1",
    observedAt: "2026-09-16T20:00:00.000Z",
    authorityStatus: "matilda_authored_interpretive_evidence",
    payload: { entryId: "iel-1" },
    persistedAt: "2026-09-17T00:00:00.000Z",
  }, sqlite);

  persistAtlasHistoricalObservation({
    sourceKind: "living_draft",
    sourceIdentity: atlasLivingDraftSourceIdentity(
      "draft-1",
      "2026-09-16T20:01:00.000Z",
    ),
    projectId: "hq",
    conversationId: "conversation-1",
    lineageId: "lineage-1",
    observedAt: "2026-09-16T20:01:00.000Z",
    authorityStatus: "non_authoritative",
    payload: {
      draftPackageId: "draft-1",
      updatedAt: "2026-09-16T20:01:00.000Z",
    },
    persistedAt: "2026-09-17T00:00:01.000Z",
  }, sqlite);

  const result =
    readAtlasHistoricalObservations("hq", sqlite);

  assert.deepEqual(
    result.map((record) => record.sourceKind),
    ["interpretation_evidence", "living_draft"],
  );

  sqlite.close();
});
TS

printf '\n=== FORMAT / TYPECHECK TARGETS CREATED ===\n'
ls -l \
  db/atlas-historical-observation-persistence.ts \
  db/atlas-historical-observation-persistence.test.ts

printf '\n=== RUN BOUNDED TEST ===\n'
npx tsx --test \
  db/atlas-historical-observation-persistence.test.ts

printf '\n=== RUN TYPESCRIPT BUILD ===\n'
npx tsc --noEmit

printf '\n=== VERIFY ONLY AUTHORIZED NEW TRACKED PATHS ===\n'
git status --short \
  db/atlas-historical-observation-persistence.ts \
  db/atlas-historical-observation-persistence.test.ts

unexpected_after="$(
  git diff --name-only |
  while IFS= read -r path; do
    case "$path" in
      ".DS_Store"|\
      "scripts/diagnose-live-selected-context-identities.ts"|\
      "scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts"|\
      "scripts/utils/ollamaChat.structured-evidence-object.test.ts"|\
      "scripts/utils/ollamaChat.ts")
        ;;
      *)
        printf '%s\n' "$path"
        ;;
    esac
  done
)"

if [ -n "$unexpected_after" ]; then
  echo "FAIL CLOSED: unexpected tracked mutation:"
  printf '%s\n' "$unexpected_after"
  exit 1
fi

echo
echo "=== ATTEMPT 1 IMPLEMENTATION COMPLETE ==="
echo "Persistence primitive implemented and tested."
echo "Workflow integration intentionally NOT implemented."
echo "No commit performed."
echo "No push performed."
