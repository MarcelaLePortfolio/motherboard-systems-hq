
import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

const db = new Database("motherboard.sqlite");

sqlite.exec(`

CREATE TABLE IF NOT EXISTS matilda_routing (

  routing_id TEXT PRIMARY KEY,

  envelope_id TEXT NOT NULL,

  package_id TEXT NOT NULL,

  lineage_id TEXT NOT NULL,

  routing_destination TEXT NOT NULL,

  routing_rationale TEXT NOT NULL,

  routing_timestamp TEXT NOT NULL,

  status TEXT NOT NULL,

  created_at TEXT NOT NULL

);

`);

export function createRouting({

  envelope_id,

  package_id,

  lineage_id,

  routing_destination,

}: {

  envelope_id: string;

  package_id: string;

  lineage_id: string;

  routing_destination: string;

}) {

  const created_at = new Date().toISOString();

  const routing_id = `routing-${randomUUID()}`;

  const routing_rationale =

    "Envelope satisfies governance requirements and is eligible for assignment.";

  sqlite.prepare(`

    INSERT INTO matilda_routing (

      routing_id,

      envelope_id,

      package_id,

      lineage_id,

      routing_destination,

      routing_rationale,

      routing_timestamp,

      status,

      created_at

    )

    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)

  `).run(

    routing_id,

    envelope_id,

    package_id,

    lineage_id,

    routing_destination,

    routing_rationale,

    created_at,

    "routing_completed",

    created_at

  );

  return {

    routing_id,

    envelope_id,

    package_id,

    lineage_id,

    routing_destination,

    routing_rationale,

    routing_timestamp: created_at,

    status: "routing_completed",

    created_at,

    assignment_authorized: false,

    execution_authorized: false,

  };

}

