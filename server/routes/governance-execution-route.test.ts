import test from "node:test";
import assert from "node:assert/strict";
import Database from "better-sqlite3";

import {
  handleGovernanceExecutionRouteRequest,
} from "./governance-execution-route";

function createDb() {
  const db = new Database(":memory:");

  db.exec(`
    CREATE TABLE governance_envelopes (
      envelope_id TEXT PRIMARY KEY,
      package_id TEXT NOT NULL,
      package_version INTEGER NOT NULL,
      delegation_id TEXT NOT NULL,
      validation_result_id TEXT NOT NULL,
      envelope_gate_id TEXT NOT NULL
    );
  `);

  db.prepare(`
    INSERT INTO governance_envelopes
    VALUES (?, ?, ?, ?, ?, ?)
  `).run(
    "e1",
    "p1",
    1,
    "d1",
    "v1",
    "g1",
  );

  return db;
}

const approval = {
  approval_id: "a1",
  envelope_id: "e1",
  package_id: "p1",
  package_version: 1,
  approved_by: "marcela",
  approval_scope: "corridor_6",
  commit_authorized: true,
  push_authorized: false,
  remote: "origin",
  branch: "feature/support-source-references-runtime",
  issued_at: "2026-08-27T22:54:00.000Z",
  expires_at: null,
  justification: "bounded route test",
  status: "approved",
  created_at: "2026-08-27T22:54:00.000Z",
};

const scope = {
  approval_id: "a1",
  envelope_id: "e1",
  package_id: "p1",
  package_version: 1,
  repo_path: "/tmp/repo",
  expected_head:
    "1111111111111111111111111111111111111111",
  allowed_paths: ["server/routes/"],
  forbidden_paths: [".env"],
  scope_constraints: "bounded route test",
  branch: "feature/support-source-references-runtime",
  created_at: "2026-08-27T22:54:00.000Z",
};

const governance = {
  delegation: {
    delegation_id: "d1",
    project_id: "hq",
    package_id: "p1",
    package_version: 1,
    authorization_state: "AUTHORIZED",
    authorization_timestamp:
      "2026-08-27T22:54:00.000Z",
    delegated_by: "marcela",
    created_at: "2026-08-27T22:54:00.000Z",
  },
  validation_result: {
    validation_result_id: "v1",
    package_id: "p1",
    package_version: 1,
    delegation_id: "d1",
    validation_status: "VALIDATION_PASSED",
    governance_findings: null,
    operational_requirements: null,
    capability_requirements: null,
    escalations: null,
    validation_timestamp:
      "2026-08-27T22:54:00.000Z",
    created_at: "2026-08-27T22:54:00.000Z",
  },
  envelope_gate: {
    envelope_gate_id: "g1",
    package_id: "p1",
    package_version: 1,
    delegation_id: "d1",
    validation_result_id: "v1",
    gate_status: "OPEN",
    gate_reason: null,
    gate_decision_timestamp:
      "2026-08-27T22:54:00.000Z",
    created_at: "2026-08-27T22:54:00.000Z",
  },
  envelope: {
    envelope_id: "e1",
    package_id: "p1",
    package_version: 1,
    delegation_id: "d1",
    validation_result_id: "v1",
    envelope_gate_id: "g1",
    validation_status: "VALIDATION_PASSED",
    required_capabilities: "governed_git_commit",
    operational_corridor: "corridor_6",
    lifecycle_state: "ready",
    created_at: "2026-08-27T22:54:00.000Z",
  },
  governance: {
    ok: true as const,
    authorization_state: "AUTHORIZED",
    validation_status: "VALIDATION_PASSED",
    gate_status: "OPEN",
  },
};

const compiledApproval = {
  approval_id: "a1",
  approved_by: "marcela",
  approval_scope: "corridor_6",
  mutation_authorized: false,
  shell_execution_authorized: false,
  autonomous_execution_authorized: false,
  version_control_authorization: {
    commit_authorized: true,
    push_authorized: false,
    remote: "origin",
    branch: "feature/support-source-references-runtime",
  },
  issued_at: "2026-08-27T22:54:00.000Z",
  expires_at: null,
  justification: "bounded route test",
  status: "approved",
};

function deps(overrides: Record<string, unknown> = {}) {
  return {
    db: createDb(),
    load_approval: () => approval as any,
    load_scope: () => scope as any,
    load_governance_chain: () =>
      governance as any,
    compile_approval: () =>
      compiledApproval as any,
    evaluate_approval: () => ({
      ok: true,
      version_control_authorization: {
        commit_authorized: false,
        push_authorized: false,
      },
    }),
    execute_commit: (() => {
      assert.fail("real commit effect must not run");
    }) as any,
    execute_push: (() => {
      assert.fail("real push effect must not run");
    }) as any,
    persist_reconciliation_entry: (() => ({
      entry_id: 1,
    })) as any,
    ...overrides,
  };
}

test(
  "invokes production entry point with injected approval evaluator",
  () => {
    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x1",
          commit_requested: false,
          push_requested: false,
        },
        deps(),
      );

    assert.equal(result.ok, true);
    assert.equal(
      (result as any).execution.execution_id,
      "x1",
    );
    assert.equal(
      result.production_approval_gate_bound,
      false,
    );
  },
);

test(
  "rejects client-authored authority fields",
  () => {
    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x1",
          commit_requested: false,
          push_requested: false,
          approved_by: "client",
          commit_authorized: true,
        },
        deps(),
      );

    assert.equal(result.ok, false);
    assert.match(
      (result as any).findings[0],
      /client-authored authority fields/,
    );
  },
);

test(
  "fails closed on package lineage mismatch",
  () => {
    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x1",
          commit_requested: false,
          push_requested: false,
        },
        deps({
          load_approval: () => ({
            ...approval,
            package_id: "wrong",
          }),
        }),
      );

    assert.equal(result.ok, false);
    assert.match(
      (result as any).findings[0],
      /package lineage mismatch/,
    );
  },
);

test(
  "fails closed when governance chain rejects",
  () => {
    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x1",
          commit_requested: false,
          push_requested: false,
        },
        deps({
          load_governance_chain: () => {
            throw new Error(
              "governance chain rejected",
            );
          },
        }),
      );

    assert.equal(result.ok, false);
    assert.match(
      (result as any).findings[0],
      /governance chain rejected/,
    );
  },
);

test(
  "rejects push without commit",
  () => {
    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x1",
          commit_requested: false,
          push_requested: true,
        },
        deps(),
      );

    assert.equal(result.ok, false);
    assert.match(
      (result as any).findings[0],
      /push without commit/,
    );
  },
);


test(
  "records reconciliation for no-effect execution",
  () => {
    const stages: string[] = [];

    const result =
      handleGovernanceExecutionRouteRequest(
        {
          approval_id: "a1",
          envelope_id: "e1",
          execution_id: "x-reconcile-no-effect",
          commit_requested: false,
          push_requested: false,
        },
        deps({
          persist_reconciliation_entry:
            ((_db: unknown, input: any) => {
              stages.push(input.stage);
              return { entry_id: stages.length };
            }) as any,
        }),
      );

    assert.equal(result.ok, true);
    assert.deepEqual(
      stages,
      [
        "EXECUTION_STARTED",
        "EXECUTION_NO_EFFECT_COMPLETED",
      ],
    );
  },
);
