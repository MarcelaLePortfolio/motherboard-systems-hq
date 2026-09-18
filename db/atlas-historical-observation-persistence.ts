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
  databasePathOrDb: string | any = "db/main.db",
): AtlasHistoricalObservationRecord[] {
  const suppliedDatabase =
    typeof databasePathOrDb === "string"
      ? null
      : databasePathOrDb;

  const sqlite =
    suppliedDatabase ??
    new Database(databasePathOrDb as string);

  const ownsConnection = suppliedDatabase === null;

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
