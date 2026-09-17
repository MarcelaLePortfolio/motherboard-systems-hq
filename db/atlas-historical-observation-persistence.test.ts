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
