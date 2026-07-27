import Database from "better-sqlite3";

import type { GovernanceLifecyclePersistenceResult } from "./governance-lifecycle-composition";

export function ensureGovernanceLifecycleEventTable(sqlite: any): void {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL,
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id)
    );

    CREATE INDEX IF NOT EXISTS idx_governance_lifecycle_events_envelope
      ON governance_lifecycle_events (envelope_id, persisted_at);
  `);
}

export function persistGovernanceEnvelopeLifecycleTransition({
  envelope_id,
  transition_authorization,
  persisted_at,
  db,
}: {
  envelope_id: string;
  transition_authorization: any;
  persisted_at: string;
  db?: any;
}): GovernanceLifecyclePersistenceResult {
  const sqlite = db ?? new Database("db/main.db");

  ensureGovernanceLifecycleEventTable(sqlite);

  const transaction = sqlite.transaction(() => {
    const envelope = sqlite
      .prepare(`
        SELECT lifecycle_state
        FROM governance_envelopes
        WHERE envelope_id = ?
      `)
      .get(envelope_id) as { lifecycle_state: string } | undefined;

    if (!envelope) {
      throw new Error(`Governance envelope not found: ${envelope_id}`);
    }

    if (envelope.lifecycle_state !== "ENVELOPE_CREATED") {
      throw new Error(
        `Governance envelope ${envelope_id} cannot transition from ${envelope.lifecycle_state} to ASSIGNED`,
      );
    }

    sqlite
      .prepare(`
        INSERT INTO governance_lifecycle_events (
          envelope_id,
          transition_authorization,
          persisted_at
        ) VALUES (?, ?, ?)
      `)
      .run(
        envelope_id,
        JSON.stringify(transition_authorization),
        persisted_at,
      );

    sqlite
      .prepare(`
        UPDATE governance_envelopes
        SET lifecycle_state = 'ASSIGNED'
        WHERE envelope_id = ?
          AND lifecycle_state = 'ENVELOPE_CREATED'
      `)
      .run(envelope_id);
  });

  transaction();

  return {
    envelope_id,
    persisted_at,
    previous_lifecycle_state: "ENVELOPE_CREATED" as const,
    lifecycle_state: "ASSIGNED" as const,
    transition: "ENVELOPE_CREATED_TO_ASSIGNED" as const,
    mutation_authorized: false,
    execution_authorized: false,
  };
}
