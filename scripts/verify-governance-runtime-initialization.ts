import assert from "node:assert/strict";
import Database from "better-sqlite3";

import { ensureGovernanceRuntimeTables } from "../db/governance-runtime";

const expectedTables = [
  "governance_delegations",
  "governance_envelope_gates",
  "governance_envelopes",
  "governance_lifecycle_events",
  "governance_packages",
  "governance_validation_results",
];

ensureGovernanceRuntimeTables();

const sqlite = new Database("db/main.db");

try {
  const actualTables = sqlite
    .prepare(`
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name LIKE 'governance_%'
      ORDER BY name
    `)
    .all()
    .map((row: any) => row.name);

  assert.deepEqual(
    actualTables,
    expectedTables,
    "Canonical governance initialization must create all six governance tables."
  );

  const lifecycleIndex = sqlite
    .prepare(`
      SELECT name
      FROM sqlite_master
      WHERE type = 'index'
        AND name = 'idx_governance_lifecycle_events_envelope'
    `)
    .get();

  assert.ok(
    lifecycleIndex,
    "Lifecycle index was not created."
  );

  console.log("Governance runtime initialization verification passed.");
} finally {
  sqlite.close();
}
