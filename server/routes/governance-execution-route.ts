import express from "express";
import type Database from "better-sqlite3";

import {
  loadGovernanceExecutionApproval,
} from "../../db/governance-execution-approval-persistence.js";
import {
  loadGovernanceExecutionScope,
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

type GovernanceExecutionApprovalRecord =
  ReturnType<typeof loadGovernanceExecutionApproval>;

type GovernanceExecutionScopeRecord =
  ReturnType<typeof loadGovernanceExecutionScope>;

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
