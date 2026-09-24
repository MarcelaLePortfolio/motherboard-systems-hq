#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b15af36b9"

READER="db/governance-envelope-gate-validation-read-repository.ts"
READER_TEST="db/governance-envelope-gate-validation-read-repository.test.ts"
CONSUMER="server/gate/production-envelope-gate-consumer.ts"
CONSUMER_TEST="server/gate/production-envelope-gate-consumer.test.ts"
ROUTE="server/routes/governance-envelope-gate-route.ts"
ROUTE_TEST="server/routes/governance-envelope-gate-route.test.ts"

TARGETS=(
  "$READER"
  "$READER_TEST"
  "$CONSUMER"
  "$CONSUMER_TEST"
  "$ROUTE"
  "$ROUTE_TEST"
)

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

test ! -e "$READER"
test ! -e "$READER_TEST"

for f in "$CONSUMER" "$CONSUMER_TEST" "$ROUTE" "$ROUTE_TEST"; do
  test -z "$(git diff -- "$f")"
done

restore_targets() {
  git restore --staged --worktree -- \
    "$CONSUMER" \
    "$CONSUMER_TEST" \
    "$ROUTE" \
    "$ROUTE_TEST" 2>/dev/null || true
  rm -f "$READER" "$READER_TEST"
}

on_error() {
  rc=$?
  printf '\nREVISED_HYPOTHESIS_ATTEMPT_1=FAILED\n'
  printf 'FAILURE_EXIT_CODE=%s\n' "$rc"
  restore_targets
  exit "$rc"
}

trap on_error ERR

cat > "$READER" << 'TS'
import Database, { type Database as DatabaseType } from "better-sqlite3";

export type GovernanceEnvelopeGateValidationIdentity = {
  validation_result_id: string;
  delegation_id: string;
  package_id: string;
  package_version: number;
};

export type GovernanceEnvelopeGateValidationReadRecord = {
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

export type GovernanceEnvelopeGateValidationLoader = (
  identity: GovernanceEnvelopeGateValidationIdentity,
) => GovernanceEnvelopeGateValidationReadRecord;

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(
      `Missing required governance Envelope Gate validation read field: ${field}`,
    );
  }

  return value.trim();
}

function requirePackageVersion(value: unknown): number {
  if (!Number.isInteger(value) || Number(value) < 1) {
    throw new Error(
      "Missing required governance Envelope Gate validation read field: package_version",
    );
  }

  return Number(value);
}

export function loadExactGovernanceEnvelopeGateValidationResult(
  db: DatabaseType,
  identity: GovernanceEnvelopeGateValidationIdentity,
): GovernanceEnvelopeGateValidationReadRecord {
  const validation_result_id = requireText(
    identity.validation_result_id,
    "validation_result_id",
  );
  const delegation_id = requireText(identity.delegation_id, "delegation_id");
  const package_id = requireText(identity.package_id, "package_id");
  const package_version = requirePackageVersion(identity.package_version);

  const rows = db.prepare(`
    SELECT
      validation_result_id,
      package_id,
      package_version,
      delegation_id,
      validation_status,
      governance_findings,
      operational_requirements,
      capability_requirements,
      escalations,
      validation_timestamp,
      created_at
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
  ) as GovernanceEnvelopeGateValidationReadRecord[];

  if (rows.length !== 1) {
    throw new Error(
      "Governance Envelope Gate validation result not found or ambiguous.",
    );
  }

  return rows[0];
}

export function createGovernanceEnvelopeGateValidationLoader(
  databasePath = "db/main.db",
): GovernanceEnvelopeGateValidationLoader {
  return (identity) => {
    const db = new Database(databasePath, {
      readonly: true,
      fileMustExist: true,
    });

    try {
      return loadExactGovernanceEnvelopeGateValidationResult(db, identity);
    } finally {
      db.close();
    }
  };
}
TS

cat > "$READER_TEST" << 'TS'
import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  loadExactGovernanceEnvelopeGateValidationResult,
} from "./governance-envelope-gate-validation-read-repository";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
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
    )
  `);

  return db;
}

function seed(
  db: Database.Database,
  overrides: Partial<{
    validation_result_id: string;
    package_id: string;
    package_version: number;
    delegation_id: string;
    validation_status: string;
  }> = {},
) {
  const row = {
    validation_result_id: "validation-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_status: "VALIDATION_PASSED",
    ...overrides,
  };

  db.prepare(`
    INSERT INTO governance_validation_results (
      validation_result_id,
      package_id,
      package_version,
      delegation_id,
      validation_status,
      governance_findings,
      operational_requirements,
      capability_requirements,
      escalations,
      validation_timestamp,
      created_at
    ) VALUES (?, ?, ?, ?, ?, NULL, NULL, NULL, NULL, ?, ?)
  `).run(
    row.validation_result_id,
    row.package_id,
    row.package_version,
    row.delegation_id,
    row.validation_status,
    "2026-09-23T20:00:00.000Z",
    "2026-09-23T20:00:00.000Z",
  );

  return row;
}

const identity = {
  validation_result_id: "validation-1",
  delegation_id: "delegation-1",
  package_id: "package-1",
  package_version: 1,
};

test("loads exactly one correlated Validation result", () => {
  const db = createDb();
  seed(db);

  const result = loadExactGovernanceEnvelopeGateValidationResult(db, identity);

  assert.equal(result.validation_result_id, identity.validation_result_id);
  assert.equal(result.delegation_id, identity.delegation_id);
  assert.equal(result.package_id, identity.package_id);
  assert.equal(result.package_version, identity.package_version);
  assert.equal(result.validation_status, "VALIDATION_PASSED");
});

test("fails closed when Validation result is missing", () => {
  const db = createDb();

  assert.throws(
    () => loadExactGovernanceEnvelopeGateValidationResult(db, identity),
    /not found or ambiguous/,
  );
});

test("fails closed on wrong package", () => {
  const db = createDb();
  seed(db);

  assert.throws(
    () =>
      loadExactGovernanceEnvelopeGateValidationResult(db, {
        ...identity,
        package_id: "wrong-package",
      }),
    /not found or ambiguous/,
  );
});

test("fails closed on wrong package version", () => {
  const db = createDb();
  seed(db);

  assert.throws(
    () =>
      loadExactGovernanceEnvelopeGateValidationResult(db, {
        ...identity,
        package_version: 2,
      }),
    /not found or ambiguous/,
  );
});

test("fails closed on wrong delegation", () => {
  const db = createDb();
  seed(db);

  assert.throws(
    () =>
      loadExactGovernanceEnvelopeGateValidationResult(db, {
        ...identity,
        delegation_id: "wrong-delegation",
      }),
    /not found or ambiguous/,
  );
});
TS

python3 - <<'PY'
from pathlib import Path

p = Path("server/gate/production-envelope-gate-consumer.ts")
s = p.read_text()

insert = '''import {
  createGovernanceEnvelopeGateValidationLoader,
  type GovernanceEnvelopeGateValidationLoader,
} from "../../db/governance-envelope-gate-validation-read-repository.js";

import {
  assertEnvelopeCreationEligible,
} from "../../db/governance-lifecycle-enforcement.js";

'''

marker = 'import {\n\n  invokeProductionEnvelopeGateEntryPoint,'
idx = s.find(marker)
if idx == -1:
    raise SystemExit("consumer import marker not found")
s = s[:idx] + insert + s[idx:]

s = s.replace(
'''  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

};''',
'''  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

  load_exact_governance_validation_result?: GovernanceEnvelopeGateValidationLoader;

};''',
1,
)

helper = '''
function failedClosed(findings: string[]): ProductionEnvelopeGateConsumerResult {

  return {

    ok: false,

    entry_point: "production_envelope_gate_entry_point",

    endpoint_authorized: false,

    scheduler_authorized: false,

    worker_claim_authorized: false,

    orchestration_authorized: false,

    routing_authorized: false,

    assignment_authorized: false,

    lifecycle_transition_authorized: false,

    execution_authorized: false,

    envelope_creation_authorized: false,

    new_authority_introduced: false,

    findings,

  };

}

'''

marker = 'export function consumeProductionEnvelopeGateEntryPoint('
idx = s.find(marker)
if idx == -1:
    raise SystemExit("consumer function marker not found")
s = s[:idx] + helper + s[idx:]

old = '''export function consumeProductionEnvelopeGateEntryPoint(

  input: ProductionEnvelopeGateConsumerInput,

): ProductionEnvelopeGateConsumerResult {

  return invokeProductionEnvelopeGateEntryPoint({'''

new = '''export function consumeProductionEnvelopeGateEntryPoint(

  input: ProductionEnvelopeGateConsumerInput,

): ProductionEnvelopeGateConsumerResult {

  try {

    const loadValidationResult =

      input.load_exact_governance_validation_result ??

      createGovernanceEnvelopeGateValidationLoader();

    const validationResult = loadValidationResult({

      validation_result_id: input.validation_result_id,

      delegation_id: input.delegation_id,

      package_id: input.package_id,

      package_version: input.package_version,

    });

    assertEnvelopeCreationEligible({

      validationResult,

      envelopeGate: { gate_status: "OPEN" },

      envelope: {

        required_capabilities: "envelope_gate_validation_only",

        operational_corridor: "envelope_gate_validation_only",

      },

    });

  } catch (error) {

    return failedClosed([

      `Production Envelope Gate eligibility failed closed: ${

        error instanceof Error ? error.message : String(error)

      }`,

    ]);

  }

  return invokeProductionEnvelopeGateEntryPoint({'''

if old not in s:
    raise SystemExit("consumer function body marker not found")

s = s.replace(old, new, 1)
p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path

p = Path("server/routes/governance-envelope-gate-route.ts")
s = p.read_text()

insert = '''import type {

  GovernanceEnvelopeGateValidationLoader,

} from "../../db/governance-envelope-gate-validation-read-repository.js";

'''

marker = 'import type {\n\n  GovernanceEnvelopeGatePersistenceFunction,'
idx = s.find(marker)
if idx == -1:
    raise SystemExit("route import marker not found")
s = s[:idx] + insert + s[idx:]

s = s.replace(
'''export type GovernanceEnvelopeGateRouteOptions = {

  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

};''',
'''export type GovernanceEnvelopeGateRouteOptions = {

  create_governance_envelope_gate?: GovernanceEnvelopeGatePersistenceFunction;

  load_exact_governance_validation_result?: GovernanceEnvelopeGateValidationLoader;

};''',
1,
)

s = s.replace(
'''    create_governance_envelope_gate: options.create_governance_envelope_gate,

  };''',
'''    create_governance_envelope_gate: options.create_governance_envelope_gate,

    load_exact_governance_validation_result:

      options.load_exact_governance_validation_result,

  };''',
1,
)

p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path

p = Path("server/gate/production-envelope-gate-consumer.test.ts")
s = p.read_text()

s = s.replace(
'''    gate_decision_timestamp: "2026-06-26T23:32:52.000Z",

    create_governance_envelope_gate: (input) => ({''',
'''    gate_decision_timestamp: "2026-06-26T23:32:52.000Z",

    load_exact_governance_validation_result: (identity) => ({

      ...identity,

      validation_status: "VALIDATION_PASSED",

      governance_findings: null,

      operational_requirements: null,

      capability_requirements: null,

      escalations: null,

      validation_timestamp: "2026-06-26T23:32:52.000Z",

      created_at: "2026-06-26T23:32:52.000Z",

    }),

    create_governance_envelope_gate: (input) => ({''',
1,
)

s = s.replace(
'''    gate_status: "",

    create_governance_envelope_gate: () => {''',
'''    gate_status: "",

    load_exact_governance_validation_result: (identity) => ({

      ...identity,

      validation_status: "VALIDATION_PASSED",

      governance_findings: null,

      operational_requirements: null,

      capability_requirements: null,

      escalations: null,

      validation_timestamp: "2026-06-26T23:32:52.000Z",

      created_at: "2026-06-26T23:32:52.000Z",

    }),

    create_governance_envelope_gate: () => {''',
1,
)

s += '''

test("production Envelope Gate consumer fails closed before persistence when Validation is not passed", () => {

  let createCalled = false;

  const result = consumeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: "gate-validation-failed",

    package_id: "pkg-validation-failed",

    package_version: 1,

    delegation_id: "delegation-validation-failed",

    validation_result_id: "validation-failed",

    gate_status: "OPEN",

    load_exact_governance_validation_result: (identity) => ({

      ...identity,

      validation_status: "VALIDATION_FAILED",

      governance_findings: null,

      operational_requirements: null,

      capability_requirements: null,

      escalations: null,

      validation_timestamp: "2026-06-26T23:32:52.000Z",

      created_at: "2026-06-26T23:32:52.000Z",

    }),

    create_governance_envelope_gate: () => {

      createCalled = true;

      throw new Error("must not persist");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(createCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});

test("production Envelope Gate consumer fails closed before persistence when exact Validation read fails", () => {

  let createCalled = false;

  const result = consumeProductionEnvelopeGateEntryPoint({

    envelope_gate_id: "gate-validation-missing",

    package_id: "pkg-validation-missing",

    package_version: 1,

    delegation_id: "delegation-validation-missing",

    validation_result_id: "validation-missing",

    gate_status: "OPEN",

    load_exact_governance_validation_result: () => {

      throw new Error("Governance Envelope Gate validation result not found or ambiguous.");

    },

    create_governance_envelope_gate: () => {

      createCalled = true;

      throw new Error("must not persist");

    },

  });

  assert.equal(result.ok, false);

  assert.equal(createCalled, false);

  assert.equal(result.endpoint_authorized, false);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});
'''

p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path

p = Path("server/routes/governance-envelope-gate-route.test.ts")
s = p.read_text()

loader = '''      load_exact_governance_validation_result: (identity) => ({

        ...identity,

        validation_status: "VALIDATION_PASSED",

        governance_findings: null,

        operational_requirements: null,

        capability_requirements: null,

        escalations: null,

        validation_timestamp: "2026-06-26T23:32:52.000Z",

        created_at: "2026-06-26T23:32:52.000Z",

      }),

'''

first = s.find('      create_governance_envelope_gate: (input) => ({')
if first == -1:
    raise SystemExit("route success persistence marker not found")
s = s[:first] + loader + s[first:]

second = s.find('      create_governance_envelope_gate: () => {', first + len(loader))
if second == -1:
    raise SystemExit("route fail persistence marker not found")
s = s[:second] + loader + s[second:]

s += '''

test("governance Envelope Gate route threads Validation loader and fails before persistence", () => {

  let createCalled = false;

  const result = handleGovernanceEnvelopeGateRouteRequest(

    {

      envelope_gate_id: "gate-route-validation-fail",

      package_id: "pkg-route-validation-fail",

      package_version: 1,

      delegation_id: "delegation-route-validation-fail",

      validation_result_id: "validation-route-validation-fail",

      gate_status: "OPEN",

    },

    {

      load_exact_governance_validation_result: () => {

        throw new Error("Governance Envelope Gate validation result not found or ambiguous.");

      },

      create_governance_envelope_gate: () => {

        createCalled = true;

        throw new Error("must not persist");

      },

    },

  );

  assert.equal(result.ok, false);

  assert.equal(createCalled, false);

  assert.equal(result.endpoint_authorized, true);

  assert.equal(result.execution_authorized, false);

  assert.equal(result.envelope_creation_authorized, false);

  assert.equal(result.new_authority_introduced, false);

});
'''

p.write_text(s)
PY

python3 - <<'PY'
from pathlib import Path

targets = [
    Path("db/governance-envelope-gate-validation-read-repository.ts"),
    Path("db/governance-envelope-gate-validation-read-repository.test.ts"),
    Path("server/gate/production-envelope-gate-consumer.ts"),
    Path("server/gate/production-envelope-gate-consumer.test.ts"),
    Path("server/routes/governance-envelope-gate-route.ts"),
    Path("server/routes/governance-envelope-gate-route.test.ts"),
]

for path in targets:
    text = path.read_text()
    path.write_text("\n".join(line.rstrip() for line in text.splitlines()) + "\n")
PY

printf '\n=== GATE 1: DIFF CHECK ===\n'
git diff --check

printf '\n=== GATE 2: TYPECHECK ===\n'
npm run check

printf '\n=== GATE 3: READER TESTS ===\n'
./node_modules/.bin/tsx --test "$READER_TEST"

printf '\n=== GATE 4: CONSUMER + ROUTE TESTS ===\n'
./node_modules/.bin/tsx --test \
  "$CONSUMER_TEST" \
  "$ROUTE_TEST" \
  server/gate/production-envelope-gate-entry-point.test.ts

printf '\n=== AUTHORIZED TARGET STATUS ===\n'
git status --short -- "${TARGETS[@]}"

git add -- "${TARGETS[@]}"

test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "6"

for f in "${TARGETS[@]}"; do
  git diff --cached --name-only | grep -Fxq "$f"
done

git commit -m "Enforce envelope gate validation eligibility"
git push origin "$BRANCH"
git fetch origin "$BRANCH"

test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

trap - ERR

printf '\n=== REVISED HYPOTHESIS ATTEMPT 1 RESULT ===\n'
echo "ENVELOPE_GATE_VALIDATION_ELIGIBILITY=IMPLEMENTED"
echo "EXACT_VALIDATION_LINEAGE_REQUIRED=YES"
echo "VALIDATION_PASSED_REQUIRED=YES"
echo "ELIGIBILITY_BEFORE_GATE_PERSISTENCE=YES"
echo "ROUTE_DEPENDENCY_THREADING=YES"
echo "ENTRY_POINT_CHANGE=NONE"
echo "SCHEMA_CHANGE=NONE"
echo "CLIENT_CHANGE=NONE"
echo "EXECUTION_AUTHORITY=NONE"
echo "NEW_AUTHORITY=NONE"
echo "IMPLEMENTATION_HEAD=$(git rev-parse --short=9 HEAD)"
