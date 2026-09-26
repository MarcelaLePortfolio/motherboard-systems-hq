import crypto from "node:crypto";
import Database from "better-sqlite3";

const db = new Database("db/main.db");

export type MatildaExecutionPlan = {
  execution_plan_id: string;
  assignment_id: string;
  package_id: string;
  lineage_id: string;
  assigned_agent: string;
  planned_steps: string[];
  planned_mutations: string[];
  rollback_references: string[];
  ambiguity_findings: string[];
  reconciliation_summary: string;
  status: "plan_review_ready";
  created_at: string;
  preview_generated: false;
  preview_confirmed: false;
  execution_authorized: false;
};

function ensureExecutionPlanSchema(): void {
  db.exec(`
    CREATE TABLE IF NOT EXISTS matilda_execution_plans (
      execution_plan_id TEXT PRIMARY KEY,
      assignment_id TEXT NOT NULL,
      package_id TEXT NOT NULL,
      lineage_id TEXT NOT NULL,
      assigned_agent TEXT NOT NULL,
      plan_json TEXT NOT NULL,
      status TEXT NOT NULL,
      created_at TEXT NOT NULL
    );

    CREATE INDEX IF NOT EXISTS idx_matilda_execution_plans_package_lineage
      ON matilda_execution_plans (package_id, lineage_id);
  `);
}

export function loadExecutionPlan(
  execution_plan_id: string,
): MatildaExecutionPlan | null {
  ensureExecutionPlanSchema();

  const row = db.prepare(`
    SELECT plan_json
    FROM matilda_execution_plans
    WHERE execution_plan_id = ?
    LIMIT 1
  `).get(execution_plan_id) as { plan_json: string } | undefined;

  return row
    ? JSON.parse(row.plan_json) as MatildaExecutionPlan
    : null;
}

export function createExecutionPlan({
  assignment_id,
  package_id,
  lineage_id,
  assigned_agent,
}: {
  assignment_id: string;
  package_id: string;
  lineage_id: string;
  assigned_agent: string;
}): MatildaExecutionPlan {
  ensureExecutionPlanSchema();

  const created_at = new Date().toISOString();
  const execution_plan_id = `plan-${crypto.randomUUID()}`;

  const plan: MatildaExecutionPlan = {
    execution_plan_id,
    assignment_id,
    package_id,
    lineage_id,
    assigned_agent,
    planned_steps: [
      "Load approved Canonical Package.",
      "Verify governance corridor completion.",
      "Generate deterministic engineering sequence.",
      "Estimate affected artifacts.",
      "Prepare reconciliation preview.",
    ],
    planned_mutations: [
      "No mutations performed (dry-run).",
    ],
    rollback_references: [
      "Current HEAD",
      "Latest DR checkpoint",
    ],
    ambiguity_findings: [],
    reconciliation_summary:
      "Execution plan generated successfully. Ready for Preview generation. No execution authority granted.",
    status: "plan_review_ready",
    created_at,
    preview_generated: false,
    preview_confirmed: false,
    execution_authorized: false,
  };

  db.prepare(`
    INSERT INTO matilda_execution_plans (
      execution_plan_id,
      assignment_id,
      package_id,
      lineage_id,
      assigned_agent,
      plan_json,
      status,
      created_at
    )
    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
  `).run(
    plan.execution_plan_id,
    plan.assignment_id,
    plan.package_id,
    plan.lineage_id,
    plan.assigned_agent,
    JSON.stringify(plan),
    plan.status,
    plan.created_at,
  );

  return plan;
}
