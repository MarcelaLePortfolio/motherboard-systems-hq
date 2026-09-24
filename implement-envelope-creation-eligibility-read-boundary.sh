#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="17fdad49e"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

TARGETS=(
  "db/governance-envelope-creation-read-repository.ts"
  "db/governance-envelope-creation-read-repository.test.ts"
  "server/envelope/governance-envelope-semantics.ts"
  "server/envelope/governance-envelope-semantics.test.ts"
)

for target in "${TARGETS[@]}"; do
  test ! -e "$target"
done

mkdir -p server/envelope

cat > db/governance-envelope-creation-read-repository.ts << 'TS'
import Database, { type Database as DatabaseType } from "better-sqlite3";

export type GovernanceEnvelopeCreationIdentity = {
  validation_result_id: string;
  envelope_gate_id: string;
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceEnvelopeCreationValidationRecord = {
  validation_result_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_status: string;
  governance_findings: string | null;
  operational_requirements: string | null;
  capability_requirements: string | null;
  escalations: string | null;
  validation_timestamp: string;
  created_at: string;
};

export type GovernanceEnvelopeCreationGateRecord = {
  envelope_gate_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  gate_status: string;
  gate_reason: string | null;
  gate_decision_timestamp: string | null;
  created_at: string;
};

export type GovernanceEnvelopeCreationReadChain = {
  validation_result: GovernanceEnvelopeCreationValidationRecord;
  envelope_gate: GovernanceEnvelopeCreationGateRecord;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Missing required governance Envelope creation read field: ${field}`,
    );
  }
  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance Envelope creation read field: package_version",
    );
  }
  return Number(value);
}

function requireExactlyOne<T>(rows: T[], artifact: string): T {
  if (rows.length !== 1) {
    throw new Error(
      `Governance Envelope creation ${artifact} not found or ambiguous.`,
    );
  }
  return rows[0];
}

export function loadExactGovernanceEnvelopeCreationReadChain(
  db: DatabaseType,
  identity: GovernanceEnvelopeCreationIdentity,
): GovernanceEnvelopeCreationReadChain {
  const validation_result_id = requireText(
    identity.validation_result_id,
    "validation_result_id",
  );
  const envelope_gate_id = requireText(
    identity.envelope_gate_id,
    "envelope_gate_id",
  );
  const delegation_id = requireText(identity.delegation_id, "delegation_id");
  const package_id = requireText(identity.package_id, "package_id");
  const package_version = requirePackageVersion(identity.package_version);

  const validation_result = requireExactlyOne(
    db.prepare(`
      SELECT validation_result_id, package_id, package_version, delegation_id,
             validation_status, governance_findings, operational_requirements,
             capability_requirements, escalations, validation_timestamp, created_at
      FROM governance_validation_results
      WHERE validation_result_id = ?
        AND delegation_id = ?
        AND package_id = ?
        AND package_version = ?
      LIMIT 2
    `).all(
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceEnvelopeCreationValidationRecord[],
    "validation result",
  );

  const envelope_gate = requireExactlyOne(
    db.prepare(`
      SELECT envelope_gate_id, package_id, package_version, delegation_id,
             validation_result_id, gate_status, gate_reason,
             gate_decision_timestamp, created_at
      FROM governance_envelope_gates
      WHERE envelope_gate_id = ?
        AND validation_result_id = ?
        AND delegation_id = ?
        AND package_id = ?
        AND package_version = ?
      LIMIT 2
    `).all(
      envelope_gate_id,
      validation_result_id,
      delegation_id,
      package_id,
      package_version,
    ) as GovernanceEnvelopeCreationGateRecord[],
    "envelope gate",
  );

  return {
    validation_result,
    envelope_gate,
  };
}

export type GovernanceEnvelopeCreationReadLoader = (
  identity: GovernanceEnvelopeCreationIdentity,
) => GovernanceEnvelopeCreationReadChain;

export function createGovernanceEnvelopeCreationReadLoader(
  databasePath = "db/main.db",
): GovernanceEnvelopeCreationReadLoader {
  return (identity) => {
    const db = new Database(databasePath, {
      readonly: true,
      fileMustExist: true,
    });

    try {
      return loadExactGovernanceEnvelopeCreationReadChain(db, identity);
    } finally {
      db.close();
    }
  };
}
TS

cat > db/governance-envelope-creation-read-repository.test.ts << 'TS'
import Database from "better-sqlite3";
import test from "node:test";
import assert from "node:assert/strict";

import {
  loadExactGovernanceEnvelopeCreationReadChain,
} from "./governance-envelope-creation-read-repository.js";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_validation_results (
      validation_result_id TEXT,
      package_id TEXT,
      package_version INTEGER,
      delegation_id TEXT,
      validation_status TEXT,
      governance_findings TEXT,
      operational_requirements TEXT,
      capability_requirements TEXT,
      escalations TEXT,
      validation_timestamp TEXT,
      created_at TEXT
    );

    CREATE TABLE governance_envelope_gates (
      envelope_gate_id TEXT,
      package_id TEXT,
      package_version INTEGER,
      delegation_id TEXT,
      validation_result_id TEXT,
      gate_status TEXT,
      gate_reason TEXT,
      gate_decision_timestamp TEXT,
      created_at TEXT
    );
  `);

  return db;
}

function seedExactChain(db: Database.Database) {
  db.prepare(`
    INSERT INTO governance_validation_results VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    "validation-1",
    "package-1",
    1,
    "delegation-1",
    "VALIDATION_PASSED",
    null,
    " planning_only ",
    " engineering_planning ",
    null,
    "2026-09-24T00:00:00.000Z",
    "2026-09-24T00:00:00.000Z",
  );

  db.prepare(`
    INSERT INTO governance_envelope_gates VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    "gate-1",
    "package-1",
    1,
    "delegation-1",
    "validation-1",
    "OPEN",
    null,
    "2026-09-24T00:01:00.000Z",
    "2026-09-24T00:01:00.000Z",
  );
}

test("loads exact correlated Validation and Envelope Gate lineage", () => {
  const db = createDb();
  seedExactChain(db);

  const result = loadExactGovernanceEnvelopeCreationReadChain(db, {
    validation_result_id: "validation-1",
    envelope_gate_id: "gate-1",
    delegation_id: "delegation-1",
    package_id: "package-1",
    package_version: 1,
  });

  assert.equal(result.validation_result.validation_status, "VALIDATION_PASSED");
  assert.equal(result.envelope_gate.gate_status, "OPEN");
  db.close();
});

test("fails closed on wrong Gate lineage", () => {
  const db = createDb();
  seedExactChain(db);

  assert.throws(() =>
    loadExactGovernanceEnvelopeCreationReadChain(db, {
      validation_result_id: "validation-1",
      envelope_gate_id: "wrong-gate",
      delegation_id: "delegation-1",
      package_id: "package-1",
      package_version: 1,
    }),
  );

  db.close();
});

test("fails closed on wrong Validation lineage", () => {
  const db = createDb();
  seedExactChain(db);

  assert.throws(() =>
    loadExactGovernanceEnvelopeCreationReadChain(db, {
      validation_result_id: "wrong-validation",
      envelope_gate_id: "gate-1",
      delegation_id: "delegation-1",
      package_id: "package-1",
      package_version: 1,
    }),
  );

  db.close();
});
TS

cat > server/envelope/governance-envelope-semantics.ts << 'TS'
import type {
  GovernanceEnvelopeCreationValidationRecord,
} from "../../db/governance-envelope-creation-read-repository.js";

export type GovernanceEnvelopeSemantics = {
  required_capabilities: string;
  operational_corridor: string;
};

function requireSemanticText(value: string | null, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Authoritative Governance Envelope semantic field is missing: ${field}`,
    );
  }

  return value.trim();
}

export function resolveGovernanceEnvelopeSemantics(
  validationResult: GovernanceEnvelopeCreationValidationRecord,
): GovernanceEnvelopeSemantics {
  return {
    required_capabilities: requireSemanticText(
      validationResult.capability_requirements,
      "capability_requirements",
    ),
    operational_corridor: requireSemanticText(
      validationResult.operational_requirements,
      "operational_requirements",
    ),
  };
}
TS

cat > server/envelope/governance-envelope-semantics.test.ts << 'TS'
import test from "node:test";
import assert from "node:assert/strict";

import {
  resolveGovernanceEnvelopeSemantics,
} from "./governance-envelope-semantics.js";

const validation = {
  validation_result_id: "validation-1",
  package_id: "package-1",
  package_version: 1,
  delegation_id: "delegation-1",
  validation_status: "VALIDATION_PASSED",
  governance_findings: null,
  operational_requirements: " planning_only ",
  capability_requirements: " engineering_planning ",
  escalations: null,
  validation_timestamp: "2026-09-24T00:00:00.000Z",
  created_at: "2026-09-24T00:00:00.000Z",
};

test("uses only lossless trim-only semantic transformation", () => {
  assert.deepEqual(resolveGovernanceEnvelopeSemantics(validation), {
    required_capabilities: "engineering_planning",
    operational_corridor: "planning_only",
  });
});

test("fails closed without required capabilities", () => {
  assert.throws(() =>
    resolveGovernanceEnvelopeSemantics({
      ...validation,
      capability_requirements: " ",
    }),
  );
});

test("fails closed without operational corridor source", () => {
  assert.throws(() =>
    resolveGovernanceEnvelopeSemantics({
      ...validation,
      operational_requirements: null,
    }),
  );
});
TS

git diff --check -- "${TARGETS[@]}"
npm run check
./node_modules/.bin/tsx --test \
  db/governance-envelope-creation-read-repository.test.ts \
  server/envelope/governance-envelope-semantics.test.ts

git add -- "${TARGETS[@]}"
test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "4"

for target in "${TARGETS[@]}"; do
  git diff --cached --name-only | grep -Fxq "$target"
done

git commit -m "Implement Envelope creation eligibility read boundary"
git push origin "$BRANCH"
git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
