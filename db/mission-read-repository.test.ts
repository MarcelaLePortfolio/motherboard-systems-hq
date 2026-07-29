import { strict as assert } from "node:assert";
import Database from "better-sqlite3";

import { createMissionReadRepository } from "./mission-read-repository";

async function main(): Promise<void> {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_packages (
      package_id TEXT PRIMARY KEY,
      package_version INTEGER NOT NULL,
      project_id TEXT,
      conversation_id TEXT
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      lifecycle_state TEXT
    );

    CREATE TABLE governance_lifecycle_events (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      envelope_id TEXT NOT NULL,
      transition_authorization TEXT NOT NULL,
      persisted_at TEXT NOT NULL
    );
  `);

  const repository = createMissionReadRepository(db);

  const mission = await repository.loadMission("test-package");

  assert.equal(mission, null);

  db.close();

  console.log("Mission Read Repository unit test passed.");
}

void main();
