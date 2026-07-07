
import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

const db = new Database("motherboard.sqlite");

sqlite.exec(`

CREATE TABLE IF NOT EXISTS matilda_envelopes (

  envelope_id TEXT PRIMARY KEY,

  validation_id TEXT NOT NULL,

  delegation_id TEXT NOT NULL,

  package_id TEXT NOT NULL,

  lineage_id TEXT NOT NULL,

  required_capabilities TEXT NOT NULL,

  operational_corridor TEXT NOT NULL,

  lifecycle_state TEXT NOT NULL,

  status TEXT NOT NULL,

  created_at TEXT NOT NULL

);

`);

export function createEnvelope({

  validation_id,

  delegation_id,

  package_id,

  lineage_id,

}: {

  validation_id: string;

  delegation_id: string;

  package_id: string;

  lineage_id: string;

}) {

  const created_at = new Date().toISOString();

  const envelope_id = `envelope-${randomUUID()}`;

  const required_capabilities = [

    "routing",

    "assignment",

    "execution-planning",

  ];

  const operational_corridor =

    "Envelope -> Routing -> Assignment -> Cade Execution";

  sqlite.prepare(`

    INSERT INTO matilda_envelopes (

      envelope_id,

      validation_id,

      delegation_id,

      package_id,

      lineage_id,

      required_capabilities,

      operational_corridor,

      lifecycle_state,

      status,

      created_at

    )

    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)

  `).run(

    envelope_id,

    validation_id,

    delegation_id,

    package_id,

    lineage_id,

    JSON.stringify(required_capabilities),

    operational_corridor,

    "routing_ready",

    "envelope_created",

    created_at

  );

  return {

    envelope_id,

    validation_id,

    delegation_id,

    package_id,

    lineage_id,

    required_capabilities,

    operational_corridor,

    lifecycle_state: "routing_ready",

    status: "envelope_created",

    created_at,

    routing_authorized: false,

    assignment_authorized: false,

    execution_authorized: false,

  };

}

