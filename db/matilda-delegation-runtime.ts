
import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

const sqlite = new Database("motherboard.sqlite");

function ensureDelegationTable() {

  db.exec(`

    CREATE TABLE IF NOT EXISTS matilda_delegations (

      delegation_id TEXT PRIMARY KEY,

      package_id TEXT NOT NULL,

      lineage_id TEXT NOT NULL,

      delegated_by TEXT NOT NULL,

      delegation_target TEXT NOT NULL,

      authorization_state TEXT NOT NULL,

      authorization_timestamp TEXT NOT NULL,

      status TEXT NOT NULL,

      created_at TEXT NOT NULL

    )

  `);

}

export function createDelegation({

  package_id,

  lineage_id,

  delegated_by,

  delegation_target,

}: {

  package_id: string;

  lineage_id: string;

  delegated_by: string;

  delegation_target: string;

}) {

  ensureDelegationTable();

  const created_at = new Date().toISOString();

  const delegation_id = `delegation-${randomUUID()}`;

  db.prepare(`

    INSERT INTO matilda_delegations (

      delegation_id,

      package_id,

      lineage_id,

      delegated_by,

      delegation_target,

      authorization_state,

      authorization_timestamp,

      status,

      created_at

    ) VALUES (?,?,?,?,?,?,?,?,?)

  `).run(

    delegation_id,

    package_id,

    lineage_id,

    delegated_by,

    delegation_target,

    "authorized_for_governance_validation",

    created_at,

    "pending_governance_validation",

    created_at,

  );

  return {

    delegation_id,

    package_id,

    lineage_id,

    delegated_by,

    delegation_target,

    authorization_state: "authorized_for_governance_validation",

    authorization_timestamp: created_at,

    status: "pending_governance_validation",

    created_at,

    governance_validation_completed: false,

    envelope_created: false,

    routing_authorized: false,

    assignment_authorized: false,

    execution_authorized: false,

  };

}

