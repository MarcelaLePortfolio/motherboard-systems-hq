#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

cat > db/mission-read-repository.test.ts << 'TS'
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
      conversation_id TEXT,
      requested_outcome TEXT NOT NULL
    );

    CREATE TABLE governance_delegations (
      delegation_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      authorization_state TEXT NOT NULL,
      authorization_timestamp TEXT NOT NULL,
      delegated_by TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_validation_results (
      validation_result_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      validation_status TEXT NOT NULL,
      required_capabilities TEXT,
      operational_corridor TEXT,
      lifecycle_state TEXT NOT NULL,
      created_at TEXT NOT NULL
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
TS

printf '\n=== TARGETED BACKEND VALIDATION ===\n'
npx tsx db/mission-read-model-assembler.test.ts
npx tsx db/mission-read-repository.test.ts
npx tsx db/mission-read-model.integration.test.ts

printf '\n=== CLIENT BUILD ===\n'
npm run build --prefix client

printf '\n=== LIVE PROJECTION ===\n'
npx tsx -e '
import Database from "better-sqlite3";
import { createMissionReadRepository } from "./db/mission-read-repository.ts";
import { assembleMissionReadModel } from "./db/mission-read-model-assembler.ts";
const db = new Database("db/main.db", { readonly: true });
const repo = createMissionReadRepository(db);
const input = await repo.loadMission("corridor-smoke");
console.log(JSON.stringify(input ? assembleMissionReadModel(input) : null, null, 2));
db.close();
'

printf '\n=== WORKTREE ===\n'
git status --short
