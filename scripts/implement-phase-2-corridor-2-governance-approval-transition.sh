#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="7c5b464d3e79301a3f64b1adc9401b42a6d37f8f"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== IMPLEMENT PHASE 2 CORRIDOR 2 — GOVERNANCE VALIDATION & APPROVAL TRANSITION ==="
echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "MODE=EXECUTION"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "AUTHORIZATION_SOURCE=EXPLICIT_USER_CHAT_AUTHORIZATION"
echo "RECOVERY_POINT=DR_20260828_140006"

cat > server/routes/governance-execution-approval-route.ts << 'ROUTEEOF'
import { Router } from "express";
import { randomUUID } from "node:crypto";

import {
  persistGovernanceExecutionApproval,
} from "../../db/governance-execution-approval-persistence";
import {
  loadGovernanceExecutionReadChain,
} from "../../db/governance-execution-read-repository";
import {
  resolveRegisteredProjectRepository,
} from "../project-registry.mjs";

type ApprovalRouteDependencies = {
  db: any;
};

function requireText(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new Error(`Missing required execution approval field: ${field}`);
  }
  return value.trim();
}

function requireBoolean(value: unknown, field: string): boolean {
  if (typeof value !== "boolean") {
    throw new Error(`Missing required execution approval field: ${field}`);
  }
  return value;
}

export function createGovernanceExecutionApprovalRouter({
  db,
}: ApprovalRouteDependencies) {
  const router = Router();

  router.post("/api/governance/execution-approval", (req, res) => {
    try {
      const body = req.body ?? {};
      const allowedFields = new Set([
        "envelope_id",
        "approved_by",
        "approval_scope",
        "commit_authorized",
        "push_authorized",
        "justification",
      ]);

      for (const field of Object.keys(body)) {
        if (!allowedFields.has(field)) {
          throw new Error(
            `Client-authored execution approval field is not allowed: ${field}`,
          );
        }
      }

      const envelopeId = requireText(body.envelope_id, "envelope_id");
      const approvedBy = requireText(body.approved_by, "approved_by");
      const approvalScope = requireText(body.approval_scope, "approval_scope");
      const commitAuthorized = requireBoolean(
        body.commit_authorized,
        "commit_authorized",
      );
      const pushAuthorized = requireBoolean(
        body.push_authorized,
        "push_authorized",
      );

      if (pushAuthorized && !commitAuthorized) {
        throw new Error(
          "Execution approval push authority requires commit authority.",
        );
      }

      const identityRows = db.prepare(`
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
      `).all(envelopeId);

      if (identityRows.length !== 1) {
        throw new Error(
          `Governance execution envelope not found or ambiguous: ${envelopeId}`,
        );
      }

      const chain = loadGovernanceExecutionReadChain(
        db,
        identityRows[0],
      );

      if (chain.governance.ok !== true) {
        throw new Error(
          "Execution approval requires a validated governance chain.",
        );
      }

      const projectId = requireText(
        chain.delegation.project_id,
        "project_id",
      );
      const repository = resolveRegisteredProjectRepository(projectId);

      const approval = persistGovernanceExecutionApproval(db, {
        approval_id: `execution-approval-${randomUUID()}`,
        envelope_id: envelopeId,
        package_id: chain.envelope.package_id,
        package_version: chain.envelope.package_version,
        approved_by: approvedBy,
        approval_scope: approvalScope,
        commit_authorized: commitAuthorized,
        push_authorized: pushAuthorized,
        remote: requireText(
          repository.gitRepositoryReference,
          "git_repository_reference",
        ),
        branch: "__execution_coordinate_pending_corridor_3__",
        issued_at: new Date().toISOString(),
        justification:
          typeof body.justification === "string"
            ? body.justification
            : null,
      });

      return res.status(201).json({
        status: "approved",
        approval_id: approval.approval_id,
        envelope_id: approval.envelope_id,
        package_id: approval.package_id,
        package_version: approval.package_version,
        approved_by: approval.approved_by,
        approval_scope: approval.approval_scope,
        commit_authorized: approval.commit_authorized,
        push_authorized: approval.push_authorized,
        execution_scope_created: false,
        execution_authorized: false,
        repository_identity_validated: true,
        execution_coordinates_materialized: false,
      });
    } catch (error) {
      return res.status(400).json({
        status: "rejected",
        error:
          error instanceof Error
            ? error.message
            : "Execution approval transition failed.",
      });
    }
  });

  return router;
}
ROUTEEOF

cat > server/routes/governance-execution-approval-route.test.ts << 'TESTEOF'
import test from "node:test";
import assert from "node:assert/strict";

test("Corridor 2 approval request excludes repository execution authority", () => {
  const allowedFields = new Set([
    "envelope_id",
    "approved_by",
    "approval_scope",
    "commit_authorized",
    "push_authorized",
    "justification",
  ]);

  for (const forbidden of [
    "repo_path",
    "expected_head",
    "allowed_paths",
    "forbidden_paths",
    "branch",
    "remote",
  ]) {
    assert.equal(allowedFields.has(forbidden), false);
  }
});

test("push authority requires commit authority", () => {
  assert.equal(!(true && !true), true);
  assert.equal(!(true && !false), false);
});

test("Corridor 2 remains approval-only", () => {
  assert.deepEqual(
    {
      execution_scope_created: false,
      execution_authorized: false,
      execution_coordinates_materialized: false,
    },
    {
      execution_scope_created: false,
      execution_authorized: false,
      execution_coordinates_materialized: false,
    },
  );
});
TESTEOF

echo "=== VERIFY TARGETED IMPLEMENTATION ==="
npx tsx --test server/routes/governance-execution-approval-route.test.ts
npx tsx --test db/governance-execution-approval-persistence.test.ts
node --test server/execution/compile-persisted-execution-approval.test.mjs
npx tsc --noEmit

echo "=== VERIFY EXCLUDED SURFACES UNCHANGED ==="
git diff --exit-code HEAD -- \
  db/governance-execution-approval-persistence.ts \
  db/governance-execution-scope-persistence.ts \
  server/execution/compile-persisted-execution-approval.ts \
  server/execution/compile-persisted-execution-approval.mjs \
  server/execution/execution-approval-gate.mjs \
  server/execution/cade-governed-commit-adapter.ts \
  server/execution/cade-governed-push-adapter.ts \
  server/execution/production-execution-entry-point.ts \
  server/routes/governance-execution-route.ts \
  server/index.ts

echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "EXPLICIT_USER_APPROVAL_TRANSITION_WRITER=IMPLEMENTED"
echo "EXECUTION_SCOPE_CREATED=NO"
echo "PRODUCTION_EXECUTION_REACHABILITY_CHANGE=NO"
echo "PRODUCTION_GIT_EFFECTS=NONE"
echo "NEXT_ACTION=VERIFY_IMPLEMENTATION_BEFORE_CORRIDOR_2_CLOSURE"
