import Database from "better-sqlite3";

export type CreateOperationalIntakeRecordInput = {
  intake_id: string;
  envelope_id: string;
  assigned_department: string;
  intake_created_at?: string | null;
  db?: Database.Database;
};

export type OperationalIntakeRecord = {
  intake_id: string;
  envelope_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
  lifecycle_state_at_intake: "ASSIGNED";
  assigned_department: string;
  required_capabilities_snapshot: string | null;
  intake_status: "RECORDED";
  intake_created_at: string;
  intake_updated_at: string;
  governance_authority_preserved: true;
  lifecycle_authority_preserved: true;
  assignment_authority_preserved: true;
  routing_authorized: false;
  scheduler_authorized: false;
  worker_claim_authorized: false;
  execution_authorized: false;
};

type GovernanceEnvelopeRow = {
  envelope_id: string;
  package_id: string;
  package_version: number;
  delegation_id: string;
  validation_result_id: string;
  envelope_gate_id: string;
  required_capabilities: string | null;
  lifecycle_state: string;
};

type OperationalIntakeRecordRow = Omit<
  OperationalIntakeRecord,
  | "governance_authority_preserved"
  | "lifecycle_authority_preserved"
  | "assignment_authority_preserved"
  | "routing_authorized"
  | "scheduler_authorized"
  | "worker_claim_authorized"
  | "execution_authorized"
> & {
  governance_authority_preserved: number;
  lifecycle_authority_preserved: number;
  assignment_authority_preserved: number;
  routing_authorized: number;
  scheduler_authorized: number;
  worker_claim_authorized: number;
  execution_authorized: number;
};

const defaultSqlite = new Database("db/main.db");
defaultSqlite.pragma("foreign_keys = ON");

function requireText(
  value: string | null | undefined,
  label: string,
): string {
  const normalized = value?.trim();

  if (!normalized) {
    throw new Error(`Missing operational intake field: ${label}`);
  }

  return normalized;
}

function ensureOperationalIntakeTable(sqlite: Database.Database): void {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS operational_intake_records (
      intake_id TEXT PRIMARY KEY,
      envelope_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL,
      lifecycle_state_at_intake TEXT NOT NULL,
      assigned_department TEXT NOT NULL,
      required_capabilities_snapshot TEXT,
      intake_status TEXT NOT NULL,
      intake_created_at TEXT NOT NULL,
      intake_updated_at TEXT NOT NULL,
      governance_authority_preserved INTEGER NOT NULL,
      lifecycle_authority_preserved INTEGER NOT NULL,
      assignment_authority_preserved INTEGER NOT NULL,
      routing_authorized INTEGER NOT NULL,
      scheduler_authorized INTEGER NOT NULL,
      worker_claim_authorized INTEGER NOT NULL,
      execution_authorized INTEGER NOT NULL,
      FOREIGN KEY (envelope_id)
        REFERENCES governance_envelopes(envelope_id),
      FOREIGN KEY (package_id, package_version)
        REFERENCES governance_packages(package_id, package_version),
      FOREIGN KEY (delegation_id)
        REFERENCES governance_delegations(delegation_id),
      FOREIGN KEY (validation_result_id)
        REFERENCES governance_validation_results(validation_result_id),
      FOREIGN KEY (envelope_gate_id)
        REFERENCES governance_envelope_gates(envelope_gate_id),
      CHECK (lifecycle_state_at_intake = 'ASSIGNED'),
      CHECK (intake_status = 'RECORDED'),
      CHECK (governance_authority_preserved = 1),
      CHECK (lifecycle_authority_preserved = 1),
      CHECK (assignment_authority_preserved = 1),
      CHECK (routing_authorized = 0),
      CHECK (scheduler_authorized = 0),
      CHECK (worker_claim_authorized = 0),
      CHECK (execution_authorized = 0)
    );

    CREATE UNIQUE INDEX IF NOT EXISTS
      idx_operational_intake_records_envelope_id
      ON operational_intake_records(envelope_id);
  `);
}

export function mapOperationalIntake(
  row: OperationalIntakeRecordRow,
): OperationalIntakeRecord {
  return {
    ...row,
    lifecycle_state_at_intake: "ASSIGNED",
    intake_status: "RECORDED",
    governance_authority_preserved:
      row.governance_authority_preserved === 1,
    lifecycle_authority_preserved:
      row.lifecycle_authority_preserved === 1,
    assignment_authority_preserved:
      row.assignment_authority_preserved === 1,
    routing_authorized: row.routing_authorized === 1,
    scheduler_authorized: row.scheduler_authorized === 1,
    worker_claim_authorized: row.worker_claim_authorized === 1,
    execution_authorized: row.execution_authorized === 1,
  } as OperationalIntakeRecord;
}

export function createOperationalIntakeRecord(
  input: CreateOperationalIntakeRecordInput,
): OperationalIntakeRecord {
  const intake_id = requireText(input.intake_id, "intake_id");
  const envelope_id = requireText(input.envelope_id, "envelope_id");
  const assigned_department = requireText(
    input.assigned_department,
    "assigned_department",
  );
  const sqlite = input.db ?? defaultSqlite;
  const intake_created_at =
    input.intake_created_at?.trim() || new Date().toISOString();

  ensureOperationalIntakeTable(sqlite);

  const existing = sqlite
    .prepare(
      "SELECT * FROM operational_intake_records WHERE envelope_id = ?",
    )
    .get(envelope_id) as OperationalIntakeRecordRow | undefined;

  if (existing) {
    return mapOperationalIntake(existing);
  }

  const envelope = sqlite
    .prepare(`
      SELECT
        envelope_id,
        package_id,
        package_version,
        delegation_id,
        validation_result_id,
        envelope_gate_id,
        required_capabilities,
        lifecycle_state
      FROM governance_envelopes
      WHERE envelope_id = ?
    `)
    .get(envelope_id) as GovernanceEnvelopeRow | undefined;

  if (!envelope) {
    throw new Error(
      "Operational intake requires an existing governance envelope.",
    );
  }

  if (envelope.lifecycle_state !== "ASSIGNED") {
    throw new Error(
      "Operational intake requires envelope lifecycle_state ASSIGNED.",
    );
  }

  sqlite
    .prepare(`
      INSERT INTO operational_intake_records (
        intake_id,
        envelope_id,
        package_id,
        package_version,
        delegation_id,
        validation_result_id,
        envelope_gate_id,
        lifecycle_state_at_intake,
        assigned_department,
        required_capabilities_snapshot,
        intake_status,
        intake_created_at,
        intake_updated_at,
        governance_authority_preserved,
        lifecycle_authority_preserved,
        assignment_authority_preserved,
        routing_authorized,
        scheduler_authorized,
        worker_claim_authorized,
        execution_authorized
      ) VALUES (
        @intake_id,
        @envelope_id,
        @package_id,
        @package_version,
        @delegation_id,
        @validation_result_id,
        @envelope_gate_id,
        'ASSIGNED',
        @assigned_department,
        @required_capabilities_snapshot,
        'RECORDED',
        @intake_created_at,
        @intake_updated_at,
        1,
        1,
        1,
        0,
        0,
        0,
        0
      )
    `)
    .run({
      intake_id,
      envelope_id,
      package_id: envelope.package_id,
      package_version: envelope.package_version,
      delegation_id: envelope.delegation_id,
      validation_result_id: envelope.validation_result_id,
      envelope_gate_id: envelope.envelope_gate_id,
      assigned_department,
      required_capabilities_snapshot: envelope.required_capabilities,
      intake_created_at,
      intake_updated_at: intake_created_at,
    });

  const created = sqlite
    .prepare(
      "SELECT * FROM operational_intake_records WHERE envelope_id = ?",
    )
    .get(envelope_id) as OperationalIntakeRecordRow;

  return mapOperationalIntake(created);
}
