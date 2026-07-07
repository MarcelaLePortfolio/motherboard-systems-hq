
import { randomUUID } from "node:crypto";

import Database from "better-sqlite3";

const db = new Database("motherboard.sqlite");

db.exec(`

CREATE TABLE IF NOT EXISTS matilda_assignments (

  assignment_id TEXT PRIMARY KEY,

  routing_id TEXT NOT NULL,

  package_id TEXT NOT NULL,

  lineage_id TEXT NOT NULL,

  assigned_agent TEXT NOT NULL,

  assignment_rationale TEXT NOT NULL,

  assignment_timestamp TEXT NOT NULL,

  status TEXT NOT NULL,

  created_at TEXT NOT NULL

);

`);

export function createAssignment({

  routing_id,

  package_id,

  lineage_id,

  assigned_agent,

}: {

  routing_id: string;

  package_id: string;

  lineage_id: string;

  assigned_agent: string;

}) {

  const created_at = new Date().toISOString();

  const assignment_id = `assignment-${randomUUID()}`;

  const assignment_rationale =

    "Routing decision established assignment eligibility for the selected agent.";

  db.prepare(`

    INSERT INTO matilda_assignments (

      assignment_id,

      routing_id,

      package_id,

      lineage_id,

      assigned_agent,

      assignment_rationale,

      assignment_timestamp,

      status,

      created_at

    )

    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)

  `).run(

    assignment_id,

    routing_id,

    package_id,

    lineage_id,

    assigned_agent,

    assignment_rationale,

    created_at,

    "assignment_created",

    created_at

  );

  return {

    assignment_id,

    routing_id,

    package_id,

    lineage_id,

    assigned_agent,

    assignment_rationale,

    assignment_timestamp: created_at,

    status: "assignment_created",

    created_at,

    execution_authorized: false,

  };

}

