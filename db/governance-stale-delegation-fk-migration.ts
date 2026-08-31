import type Database from "better-sqlite3";

const STALE_DELEGATION_PARENT = "governance_delegations_legacy_root";

const affectedTables = [
  "governance_validation_results",
  "governance_envelope_gates",
  "governance_envelopes",
] as const;

type AffectedTable = (typeof affectedTables)[number];

type ForeignKeyRow = {
  table: string;
};

function hasStaleDelegationForeignKey(
  sqlite: Database.Database,
  table: AffectedTable,
): boolean {
  const rows = sqlite
    .prepare(`PRAGMA foreign_key_list("${table}")`)
    .all() as ForeignKeyRow[];

  return rows.some((row) => row.table === STALE_DELEGATION_PARENT);
}

function rebuildValidationResults(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE governance_validation_results_repaired_delegation_fk (
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
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id)
    );

    INSERT INTO governance_validation_results_repaired_delegation_fk (
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
    )
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
    FROM governance_validation_results;

    DROP TABLE governance_validation_results;

    ALTER TABLE governance_validation_results_repaired_delegation_fk
    RENAME TO governance_validation_results;
  `);
}

function rebuildEnvelopeGates(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE governance_envelope_gates_repaired_delegation_fk (
      envelope_gate_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      gate_status TEXT NOT NULL,
      gate_reason TEXT,
      gate_decision_timestamp TEXT NOT NULL,
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id)
    );

    INSERT INTO governance_envelope_gates_repaired_delegation_fk (
      envelope_gate_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      gate_status,
      gate_reason,
      gate_decision_timestamp,
      created_at
    )
    SELECT
      envelope_gate_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      gate_status,
      gate_reason,
      gate_decision_timestamp,
      created_at
    FROM governance_envelope_gates;

    DROP TABLE governance_envelope_gates;

    ALTER TABLE governance_envelope_gates_repaired_delegation_fk
    RENAME TO governance_envelope_gates;
  `);
}

function rebuildEnvelopes(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE governance_envelopes_repaired_delegation_fk (
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
      created_at TEXT NOT NULL,
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates(envelope_gate_id)
    );

    INSERT INTO governance_envelopes_repaired_delegation_fk (
      envelope_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id,
      validation_status,
      required_capabilities,
      operational_corridor,
      lifecycle_state,
      created_at
    )
    SELECT
      envelope_id,
      package_id,
      package_version,
      delegation_id,
      validation_result_id,
      envelope_gate_id,
      validation_status,
      required_capabilities,
      operational_corridor,
      lifecycle_state,
      created_at
    FROM governance_envelopes;

    DROP TABLE governance_envelopes;

    ALTER TABLE governance_envelopes_repaired_delegation_fk
    RENAME TO governance_envelopes;
  `);
}

export function repairStaleGovernanceDelegationForeignKeys(
  sqlite: Database.Database,
): boolean {
  const staleTables = affectedTables.filter((table) =>
    hasStaleDelegationForeignKey(sqlite, table),
  );

  if (staleTables.length === 0) {
    return false;
  }

  const foreignKeysWereEnabled =
    Number(sqlite.pragma("foreign_keys", { simple: true })) === 1;

  sqlite.pragma("foreign_keys = OFF");

  try {
    sqlite.transaction(() => {
      if (staleTables.includes("governance_validation_results")) {
        rebuildValidationResults(sqlite);
      }

      if (staleTables.includes("governance_envelope_gates")) {
        rebuildEnvelopeGates(sqlite);
      }

      if (staleTables.includes("governance_envelopes")) {
        rebuildEnvelopes(sqlite);
      }
    })();
  } finally {
    sqlite.pragma(
      `foreign_keys = ${foreignKeysWereEnabled ? "ON" : "OFF"}`,
    );
  }

  return true;
}
