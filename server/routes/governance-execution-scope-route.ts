import { Router } from "express";
import type { Database } from "better-sqlite3";

import {
  materializeGovernanceExecutionScope,
} from "../execution/materialize-governance-execution-scope";

type GovernanceExecutionScopeRouteDependencies = {
  db: Database;
  materialize_execution_scope?: typeof materializeGovernanceExecutionScope;
};

const ALLOWED_BODY_FIELDS = new Set([
  "approval_id",
  "envelope_id",
  "allowed_paths",
  "forbidden_paths",
  "scope_constraints",
]);

export function createGovernanceExecutionScopeRouter({
  db,
  materialize_execution_scope = materializeGovernanceExecutionScope,
}: GovernanceExecutionScopeRouteDependencies) {
  const router = Router();

  router.post("/api/governance/execution-scope", (req, res) => {
    try {
      const body = req.body ?? {};

      for (const field of Object.keys(body)) {
        if (!ALLOWED_BODY_FIELDS.has(field)) {
          throw new Error(
            `Client-authored execution scope field is not allowed: ${field}`,
          );
        }
      }

      const scope = materialize_execution_scope(db, {
        approval_id: body.approval_id,
        envelope_id: body.envelope_id,
        allowed_paths: body.allowed_paths,
        forbidden_paths: body.forbidden_paths,
        scope_constraints: body.scope_constraints,
      });

      return res.status(201).json({
        status: "materialized",
        approval_id: scope.approval_id,
        envelope_id: scope.envelope_id,
        package_id: scope.package_id,
        package_version: scope.package_version,
        repo_path: scope.repo_path,
        expected_head: scope.expected_head,
        branch: scope.branch,
        allowed_paths: scope.allowed_paths,
        forbidden_paths: scope.forbidden_paths,
        scope_constraints: scope.scope_constraints,
        execution_scope_created: true,
        execution_authorized: false,
        repository_identity_validated: true,
        execution_coordinates_materialized: true,
      });
    } catch (error) {
      return res.status(400).json({
        status: "rejected",
        error:
          error instanceof Error
            ? error.message
            : "Execution scope materialization failed.",
      });
    }
  });

  return router;
}
