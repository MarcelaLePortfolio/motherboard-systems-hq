
import Database from "better-sqlite3";

import type { GovernanceLifecycleTransitionAuthorizationResult } from "../server/ellis/lifecycle-transition-authorization";

export type PersistGovernanceEnvelopeLifecycleTransitionInput = {

  envelope_id: string;

  transition_authorization: GovernanceLifecycleTransitionAuthorizationResult;

  persisted_at?: string | null;

  db?: Database.Database;

};

export type PersistedGovernanceEnvelopeLifecycleTransition = {

  envelope_id: string;

  previous_lifecycle_state: "ENVELOPE_CREATED";

  lifecycle_state: "ASSIGNED";

  transition: "ENVELOPE_CREATED_TO_ASSIGNED";

  persisted_at: string;

  mutation_authorized: false;

  execution_authorized: false;

};

const defaultSqlite = new Database("db/main.db");

defaultSqlite.pragma("foreign_keys = ON");

function requireText(value: string | null | undefined, label: string): string {

  const normalized = value?.trim();

  if (!normalized) throw new Error(`Missing governance lifecycle persistence field: ${label}`);

  return normalized;

}

export function persistGovernanceEnvelopeLifecycleTransition(

  input: PersistGovernanceEnvelopeLifecycleTransitionInput,

): PersistedGovernanceEnvelopeLifecycleTransition {

  const envelope_id = requireText(input.envelope_id, "envelope_id");

  const sqlite = input.db ?? defaultSqlite;

  const persisted_at = input.persisted_at?.trim() || new Date().toISOString();

  if (!input.transition_authorization.ok || !input.transition_authorization.transition_authorized) {

    throw new Error("Lifecycle persistence requires a passed governance lifecycle transition authorization.");

  }

  if (

    input.transition_authorization.transition !== "ENVELOPE_CREATED_TO_ASSIGNED" ||

    input.transition_authorization.from !== "ENVELOPE_CREATED" ||

    input.transition_authorization.to !== "ASSIGNED"

  ) {

    throw new Error("Lifecycle persistence only supports ENVELOPE_CREATED -> ASSIGNED.");

  }

  const result = sqlite.prepare(`

    UPDATE governance_envelopes

    SET lifecycle_state = 'ASSIGNED'

    WHERE envelope_id = ?

      AND lifecycle_state = 'ENVELOPE_CREATED'

  `).run(envelope_id);

  if (result.changes !== 1) {

    throw new Error("Lifecycle persistence failed: envelope missing or not in ENVELOPE_CREATED state.");

  }

  return {

    envelope_id,

    previous_lifecycle_state: "ENVELOPE_CREATED",

    lifecycle_state: "ASSIGNED",

    transition: "ENVELOPE_CREATED_TO_ASSIGNED",

    persisted_at,

    mutation_authorized: false,

    execution_authorized: false,

  };

}

