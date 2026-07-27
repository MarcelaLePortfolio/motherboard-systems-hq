#!/usr/bin/env bash
set -euo pipefail

npx tsc \
  --noEmit \
  --target ES2022 \
  --module CommonJS \
  --moduleResolution Node \
  --esModuleInterop \
  --skipLibCheck \
  db/governance-lifecycle-persistence.ts

npx ts-node \
  --compiler-options '{"module":"CommonJS","moduleResolution":"Node","esModuleInterop":true,"lib":["ES2022"]}' \
  --eval '
const Database = require("better-sqlite3");
const { persistGovernanceEnvelopeLifecycleTransition } =
  require("./db/governance-lifecycle-persistence");

const sqlite = new Database(":memory:");

sqlite.exec(`
CREATE TABLE governance_envelopes (
  envelope_id TEXT PRIMARY KEY,
  lifecycle_state TEXT NOT NULL
);

INSERT INTO governance_envelopes
VALUES ("lifecycle-persistence-smoke","ENVELOPE_CREATED");
`);

const result = persistGovernanceEnvelopeLifecycleTransition({
  envelope_id: "lifecycle-persistence-smoke",
  transition_authorization: {
    ok: true,
    transition: "ENVELOPE_CREATED_TO_ASSIGNED"
  },
  persisted_at: "2026-07-27T00:00:00.000Z",
  db: sqlite
});

const envelopeRow = sqlite.prepare(
  "SELECT lifecycle_state FROM governance_envelopes WHERE envelope_id=?"
).get("lifecycle-persistence-smoke");

const lifecycleEventRow = sqlite.prepare(
  "SELECT transition_authorization FROM governance_lifecycle_events WHERE envelope_id=?"
).get("lifecycle-persistence-smoke");

if (result.lifecycle_state !== "ASSIGNED") throw new Error("Bad return state.");
if (!envelopeRow || envelopeRow.lifecycle_state !== "ASSIGNED") throw new Error("Envelope not updated.");
if (!lifecycleEventRow) throw new Error("Lifecycle event missing.");

const auth = JSON.parse(lifecycleEventRow.transition_authorization);

if (!auth.ok) throw new Error("Authorization not persisted.");

console.log("Lifecycle persistence verification passed.");
'

git diff --check
