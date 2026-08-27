#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD="a01d17364"

if [[ "$(git rev-parse HEAD)" != "$EXPECTED_HEAD"* ]]; then
  echo "STOP=UNEXPECTED_HEAD"
  echo "CURRENT_HEAD=$(git rev-parse HEAD)"
  exit 1
fi

echo "=== CORRIDOR 6 — IMPLEMENT UNMOUNTED ROUTE WITH INJECTED APPROVAL EVALUATOR ==="
echo "MODE=EXECUTION"
echo "AUTHORIZATION_SCOPE=PREVIOUSLY_AUTHORIZED_UNMOUNTED_ROUTE_ONLY"
echo "STATIC_APPROVAL_GATE_IMPORT=PROHIBITED"
echo "PRODUCTION_APPROVAL_GATE_BINDING=DEFERRED"
echo "ROUTE_MOUNT_AUTHORIZED=NO"
echo "PRODUCTION_REACHABILITY_AUTHORIZED=NO"

cat > server/routes/governance-execution-route.ts << 'ROUTE'
import express from "express";
import type Database from "better-sqlite3";

import {
  loadGovernanceExecutionApproval,
  type GovernanceExecutionApprovalRecord,
} from "../../db/governance-execution-approval-persistence.js";
import {
  loadGovernanceExecutionScope,
  type GovernanceExecutionScopeRecord,
} from "../../db/governance-execution-scope-persistence.js";
import {
  loadGovernanceExecutionReadChain,
  type GovernanceExecutionReadChain,
  type GovernanceExecutionReadIdentity,
} from "../../db/governance-execution-read-repository.js";
import {
  compilePersistedExecutionApproval,
} from "../execution/compile-persisted-execution-approval.mjs";
import {
  executeProductionExecutionEntryPoint,
  type ProductionExecutionRequest,
} from "../execution/production-execution-entry-point.js";

export type GovernanceExecutionRouteBody = {
  approval_id?: unknown;
  envelope_id?: unknown;
  execution_id?: unknown;
  commit_requested?: unknown;
  push_requested?: unknown;
  commit_message?: unknown;
  expected_remote_url?: unknown;
  [key: string]: unknown;
};

type ApprovalEvaluator = (input: {
  envelope: any;
  governance: any;
  approval: any;
  localCommitResult?: any;
}) => any;

type ExecutionEntryPoint =
  typeof executeProductionExecutionEntryPoint;

export type GovernanceExecutionRouteDependencies = {
  db: Database.Database;
  evaluate_approval: ApprovalEvaluator;
  execute_commit: (...args: any[]) => any;
  execute_push: (...args: any[]) => any;
  load_approval?: (
    db: Database.Database,
    approvalId: string,
    envelopeId: string,
  ) => GovernanceExecutionApprovalRecord;
  load_scope?: (
    db: Database.Database,
    approvalId: string,
    envelopeId: string,
  ) => GovernanceExecutionScopeRecord;
  load_governance_chain?: (
    db: Database.Database,
    identity: GovernanceExecutionReadIdentity,
  ) => GovernanceExecutionReadChain;
  compile_approval?: typeof compilePersistedExecutionApproval;
  execute_execution?: ExecutionEntryPoint;
};

const ALLOWED_BODY_FIELDS = new Set([
  "approval_id",
  "envelope_id",
  "execution_id",
  "commit_requested",
  "push_requested",
  "commit_message",
  "expected_remote_url",
]);

function requireText(
  value: unknown,
  field: string,
): string {
  if (
    typeof value !== "string" ||
    value.trim().length === 0
  ) {
    throw new Error(
      `Governance execution route requires ${field}.`,
    );
  }

  return value.trim();
}

function optionalText(
  value: unknown,
  field: string,
): string | undefined {
  if (value === undefined || value === null) {
    return undefined;
  }

  if (
    typeof value !== "string" ||
    value.trim().length === 0
  ) {
    throw new Error(
      `Governance execution route requires ${field} to be a non-empty string when supplied.`,
    );
  }

  return value.trim();
}

function requireBoolean(
  value: unknown,
  field: string,
): boolean {
  if (typeof value !== "boolean") {
    throw new Error(
      `Governance execution route requires boolean ${field}.`,
    );
  }

  return value;
}

function rejectUnexpectedFields(
  body: GovernanceExecutionRouteBody,
): void {
  const unexpected = Object.keys(body).filter(
    (key) => !ALLOWED_BODY_FIELDS.has(key),
  );

  if (unexpected.length > 0) {
    throw new Error(
      `Governance execution route rejects unsupported or client-authored authority fields: ${unexpected
        .sort()
        .join(", ")}`,
    );
  }
}

function loadEnvelopeIdentity(
  db: Database.Database,
  envelopeId: string,
): GovernanceExecutionReadIdentity {
  const rows = db
    .prepare(`
      SELECT
        envelope_id,
        package_id,
        package_version,
        delegation_id,
        validation_result_id,
        envelope_gate_id
      FROM governance_envelopes
      WHERE envelope_id = ?
      LIMIT 2
    `)
    .all(envelopeId) as GovernanceExecutionReadIdentity[];

  if (rows.length !== 1) {
    throw new Error(
      `Governance execution envelope not found or ambiguous: ${envelopeId}`,
    );
  }

  return rows[0];
}

export function handleGovernanceExecutionRouteRequest(
  body: GovernanceExecutionRouteBody,
  dependencies: GovernanceExecutionRouteDependencies,
) {
  try {
    rejectUnexpectedFields(body);

    const approvalId = requireText(
      body.approval_id,
      "approval_id",
    );
    const envelopeId = requireText(
      body.envelope_id,
      "envelope_id",
    );
    const executionId = requireText(
      body.execution_id,
      "execution_id",
    );
    const commitRequested = requireBoolean(
      body.commit_requested,
      "commit_requested",
    );
    const pushRequested = requireBoolean(
      body.push_requested,
      "push_requested",
    );
    const commitMessage = optionalText(
      body.commit_message,
      "commit_message",
    );
    const expectedRemoteUrl = optionalText(
      body.expected_remote_url,
      "expected_remote_url",
    );

    if (pushRequested && !commitRequested) {
      throw new Error(
        "Governance execution route refuses push without commit.",
      );
    }

    if (commitRequested && !commitMessage) {
      throw new Error(
        "Governance execution route requires commit_message when commit is requested.",
      );
    }

    if (pushRequested && !expectedRemoteUrl) {
      throw new Error(
        "Governance execution route requires expected_remote_url when push is requested.",
      );
    }

    const loadApproval =
      dependencies.load_approval ??
      loadGovernanceExecutionApproval;
    const loadScope =
      dependencies.load_scope ??
      loadGovernanceExecutionScope;
    const loadGovernanceChain =
      dependencies.load_governance_chain ??
      loadGovernanceExecutionReadChain;
    const compileApproval =
      dependencies.compile_approval ??
      compilePersistedExecutionApproval;
    const executeExecution =
      dependencies.execute_execution ??
      executeProductionExecutionEntryPoint;

    const approval = loadApproval(
      dependencies.db,
      approvalId,
      envelopeId,
    );

    const scope = loadScope(
      dependencies.db,
      approvalId,
      envelopeId,
    );

    const identity = loadEnvelopeIdentity(
      dependencies.db,
      envelopeId,
    );

    if (
      approval.package_id !== identity.package_id ||
      approval.package_version !== identity.package_version ||
      scope.package_id !== identity.package_id ||
      scope.package_version !== identity.package_version
    ) {
      throw new Error(
        "Governance execution route package lineage mismatch.",
      );
    }

    const governanceChain = loadGovernanceChain(
      dependencies.db,
      identity,
    );

    const compiledApproval =
      compileApproval(approval);

    const envelope = {
      identity,
      project_target: {
        repo_path: scope.repo_path,
        branch: scope.branch,
        expected_head: scope.expected_head,
      },
      mutation_scope: {
        allowed_paths: scope.allowed_paths,
        forbidden_paths: scope.forbidden_paths,
        scope_constraints:
          scope.scope_constraints,
      },
      delegation_authorization: {
        required: true,
        state: "delegated",
        delegation_id:
          governanceChain.delegation.delegation_id,
        delegated_by:
          governanceChain.delegation.delegated_by,
        authorization_state:
          governanceChain.delegation.authorization_state,
      },
    };

    const request: ProductionExecutionRequest = {
      envelope,
      governance: governanceChain.governance,
      approval: compiledApproval,
      executionId,
      commitRequested,
      pushRequested,
      commitMessage,
      expectedRemoteUrl,
    };

    const execution = executeExecution(
      request,
      {
        evaluateApproval:
          dependencies.evaluate_approval,
        executeCommit:
          dependencies.execute_commit as any,
        executePush:
          dependencies.execute_push as any,
      },
    );

    return {
      ok: true,
      route: "governance_execution_route",
      execution,
      route_mounted: false,
      production_reachability_authorized: false,
      production_approval_gate_bound: false,
      new_authority_introduced: false,
    };
  } catch (error) {
    return {
      ok: false,
      route: "governance_execution_route",
      route_mounted: false,
      production_reachability_authorized: false,
      production_approval_gate_bound: false,
      new_authority_introduced: false,
      findings: [
        error instanceof Error
          ? error.message
          : "Governance execution route failed closed.",
      ],
    };
  }
}

export function createGovernanceExecutionRouter(
  dependencies: GovernanceExecutionRouteDependencies,
): express.Router {
  const router = express.Router();

  router.post(
    "/api/governance/execution",
    (req, res) => {
      const result =
        handleGovernanceExecutionRouteRequest(
          req.body || {},
          dependencies,
        );

      return res
        .status(result.ok ? 200 : 400)
        .json(result);
    },
  );

  return router;
}
ROUTE

cat > server/routes/governance-execution-route.test.ts << 'TEST'
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
          expected_remote_url:
            "https://github.com/example/repo.git",
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
TEST

node --import tsx --test \
  server/routes/governance-execution-route.test.ts

node --import tsx --test \
  server/execution/production-execution-entry-point.test.ts

node --import tsx --test \
  db/governance-execution-read-repository.test.ts

node --import tsx --test \
  db/governance-execution-approval-persistence.test.ts

node --import tsx --test \
  db/governance-execution-scope-persistence.test.ts

npx tsc --noEmit

if grep -q \
  'execution-approval-gate.mjs' \
  server/routes/governance-execution-route.ts
then
  echo "STOP=STATIC_APPROVAL_GATE_IMPORT_PRESENT"
  exit 1
fi

if grep -q \
  'createGovernanceExecutionRouter' \
  server/index.ts
then
  echo "STOP=EXECUTION_ROUTE_UNEXPECTEDLY_MOUNTED"
  exit 1
fi

git diff --exit-code "$EXPECTED_HEAD" -- \
  server/index.ts

echo
echo "=== RESULT ==="
echo "UNMOUNTED_ROUTE_TARGETED_TESTS=5_OF_5_PASS"
echo "PRODUCTION_EXECUTION_ENTRY_POINT_REGRESSION=PASS"
echo "GOVERNANCE_READ_REGRESSION=PASS"
echo "APPROVAL_PERSISTENCE_REGRESSION=PASS"
echo "SCOPE_PERSISTENCE_REGRESSION=PASS"
echo "TYPESCRIPT=PASS"
echo "STATIC_APPROVAL_GATE_IMPORT_PRESENT=NO"
echo "INJECTED_APPROVAL_EVALUATOR_REQUIRED=YES"
echo "PRODUCTION_APPROVAL_GATE_BOUND=NO"
echo "REAL_GIT_EFFECTS_IN_ROUTE_TESTS=NO"
echo "CLIENT_AUTHORITY_FIELDS_REJECTED=YES"
echo "ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY_CHANGED=NO"
echo "SERVER_INDEX_CHANGED=NO"
echo "UNMOUNTED_EXECUTION_ROUTE_IMPLEMENTED=YES"
echo "UNMOUNTED_EXECUTION_ROUTE_VERIFIED=YES"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
echo "NEXT_ACTION=REASSESS_REMAINING_CORRIDOR_6_ACTIVATION_GAP_AFTER_VERIFIED_UNMOUNTED_ROUTE"

git status --short
