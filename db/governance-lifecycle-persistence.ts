import type { GovernanceLifecyclePersistenceResult } from "./governance-lifecycle-composition";


import Database from "better-sqlite3";

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

  const stmt = db.prepare(`

    INSERT INTO governance_lifecycle_events (

      envelope_id,

      transition_authorization,

      persisted_at

    ) VALUES (?, ?, ?)

  `);

  stmt.run(

    envelope_id,

    JSON.stringify(transition_authorization),

    persisted_at

  );

  // CRITICAL: return EXACT literal contract shape (no widening)

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

