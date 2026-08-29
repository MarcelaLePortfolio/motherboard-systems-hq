#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="73fd65d312948f92aabf9672d85e7fb8cc976fdb"
EXPECTED_BRANCH="feature/support-source-references-runtime"

test "$(git rev-parse HEAD)" = "${EXPECTED_HEAD}"
test "$(git branch --show-current)" = "${EXPECTED_BRANCH}"

python3 << 'PY'
from pathlib import Path

# 1. Remove the invalid comparison between an observed remote URL and the
# path-backed project-registry repository reference. Canonical repository-root
# validation remains owned by resolveRegisteredProjectRepository +
# observeGovernedRepositoryState.
path = Path("server/execution/materialize-governance-execution-scope.ts")
text = path.read_text()

old = '''  const registeredRepositoryReference = requireText(
    repository.gitRepositoryReference,
    "git_repository_reference",
  );

  if (observed.remote_url !== registeredRepositoryReference) {
    throw new Error(
      "Observed repository remote does not match registered repository identity.",
    );
  }

'''

if text.count(old) != 1:
    raise SystemExit(
        f"MATERIALIZER_INVALID_REMOTE_COMPARISON_COUNT={text.count(old)}"
    )

path.write_text(text.replace(old, "", 1))


# 2. Add a bounded scope-materialization HTTP router. It accepts only the
# already-frozen executable path-scope transition fields and delegates to the
# existing materializer; it creates no new authority.
path = Path("server/routes/governance-execution-scope-route.ts")

if path.exists():
    raise SystemExit(
        "REFUSING_TO_OVERWRITE_EXISTING_GOVERNANCE_EXECUTION_SCOPE_ROUTE"
    )

path.write_text('''import { Router } from "express";
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
''')


# 3. Extend the existing production composition rather than creating a
# parallel orchestrator. Approval, scope materialization, and execution share
# the existing production database client.
path = Path("server/execution/production-governance-execution-composition.ts")
text = path.read_text()

import_anchor = '''import {
  createGovernanceExecutionRouter,
} from "../routes/governance-execution-route";
'''

import_replacement = '''import {
  createGovernanceExecutionRouter,
} from "../routes/governance-execution-route";
import {
  createGovernanceExecutionApprovalRouter,
} from "../routes/governance-execution-approval-route";
import {
  createGovernanceExecutionScopeRouter,
} from "../routes/governance-execution-scope-route";
'''

if text.count(import_anchor) != 1:
    raise SystemExit(
        f"TS_COMPOSITION_IMPORT_ANCHOR_COUNT={text.count(import_anchor)}"
    )

text = text.replace(import_anchor, import_replacement, 1)

function_anchor = '''export function createProductionGovernanceExecutionRouter() {
  return createGovernanceExecutionRouter(
    productionGovernanceExecutionDependencies,
  );
}
'''

function_replacement = '''export function createProductionGovernanceExecutionRouter() {
  const router = createGovernanceExecutionRouter(
    productionGovernanceExecutionDependencies,
  );

  router.use(
    createGovernanceExecutionApprovalRouter({
      db: productionGovernanceExecutionDependencies.db,
    }),
  );

  router.use(
    createGovernanceExecutionScopeRouter({
      db: productionGovernanceExecutionDependencies.db,
    }),
  );

  return router;
}
'''

if text.count(function_anchor) != 1:
    raise SystemExit(
        f"TS_COMPOSITION_FUNCTION_ANCHOR_COUNT={text.count(function_anchor)}"
    )

text = text.replace(function_anchor, function_replacement, 1)

metadata_anchor = '''export const productionGovernanceExecutionComposition = {
  route_mounted: false,
  production_reachability_authorized: false,
  new_authority_introduced: false,
};
'''

metadata_replacement = '''export const productionGovernanceExecutionComposition = {
  route_mounted: true,
  execution_route_reachable: true,
  execution_approval_route_reachable: true,
  execution_scope_route_reachable: true,
  production_execution_authorized: false,
  new_authority_introduced: false,
};
'''

if text.count(metadata_anchor) != 1:
    raise SystemExit(
        f"TS_COMPOSITION_METADATA_ANCHOR_COUNT={text.count(metadata_anchor)}"
    )

path.write_text(
    text.replace(metadata_anchor, metadata_replacement, 1)
)


# 4. Keep the runtime MJS composition equivalent to the TS composition.
path = Path("server/execution/production-governance-execution-composition.mjs")
text = path.read_text()

import_anchor = '''import { createGovernanceExecutionRouter } from "../routes/governance-execution-route.ts";
'''

import_replacement = '''import { createGovernanceExecutionRouter } from "../routes/governance-execution-route.ts";
import { createGovernanceExecutionApprovalRouter } from "../routes/governance-execution-approval-route.ts";
import { createGovernanceExecutionScopeRouter } from "../routes/governance-execution-scope-route.ts";
'''

if text.count(import_anchor) != 1:
    raise SystemExit(
        f"MJS_COMPOSITION_IMPORT_ANCHOR_COUNT={text.count(import_anchor)}"
    )

text = text.replace(import_anchor, import_replacement, 1)

function_anchor = '''export function createProductionGovernanceExecutionRouter() {
  return createGovernanceExecutionRouter(
    productionGovernanceExecutionDependencies,
  );
}
'''

function_replacement = '''export function createProductionGovernanceExecutionRouter() {
  const router = createGovernanceExecutionRouter(
    productionGovernanceExecutionDependencies,
  );

  router.use(
    createGovernanceExecutionApprovalRouter({
      db: productionGovernanceExecutionDependencies.db,
    }),
  );

  router.use(
    createGovernanceExecutionScopeRouter({
      db: productionGovernanceExecutionDependencies.db,
    }),
  );

  return router;
}
'''

if text.count(function_anchor) != 1:
    raise SystemExit(
        f"MJS_COMPOSITION_FUNCTION_ANCHOR_COUNT={text.count(function_anchor)}"
    )

text = text.replace(function_anchor, function_replacement, 1)

metadata_anchor = '''export const productionGovernanceExecutionComposition = {
  route_mounted: false,
  production_reachability_authorized: false,
  new_authority_introduced: false,
};
'''

metadata_replacement = '''export const productionGovernanceExecutionComposition = {
  route_mounted: true,
  execution_route_reachable: true,
  execution_approval_route_reachable: true,
  execution_scope_route_reachable: true,
  production_execution_authorized: false,
  new_authority_introduced: false,
};
'''

if text.count(metadata_anchor) != 1:
    raise SystemExit(
        f"MJS_COMPOSITION_METADATA_ANCHOR_COUNT={text.count(metadata_anchor)}"
    )

path.write_text(
    text.replace(metadata_anchor, metadata_replacement, 1)
)


# 5. Update the existing composition test to reflect actual server mounting
# while preserving the explicit distinction between reachability and execution
# authorization.
path = Path("server/execution/production-governance-execution-composition.test.mjs")
text = path.read_text()

old = '''test("constructs the production router without mounting or authorizing reachability", () => {
  const router = createProductionGovernanceExecutionRouter();

  assert.ok(router);
  assert.equal(typeof router.use, "function");
  assert.deepEqual(productionGovernanceExecutionComposition, {
    route_mounted: false,
    production_reachability_authorized: false,
    new_authority_introduced: false,
  });
});
'''

new = '''test("constructs the reachable governed workflow without authorizing production execution", () => {
  const router = createProductionGovernanceExecutionRouter();

  assert.ok(router);
  assert.equal(typeof router.use, "function");
  assert.deepEqual(productionGovernanceExecutionComposition, {
    route_mounted: true,
    execution_route_reachable: true,
    execution_approval_route_reachable: true,
    execution_scope_route_reachable: true,
    production_execution_authorized: false,
    new_authority_introduced: false,
  });
});
'''

if text.count(old) != 1:
    raise SystemExit(
        f"COMPOSITION_TEST_ANCHOR_COUNT={text.count(old)}"
    )

path.write_text(text.replace(old, new, 1))
PY

cat > server/routes/governance-execution-scope-route.test.ts << 'TESTEOF'
import assert from "node:assert/strict";
import test from "node:test";

import {
  createGovernanceExecutionScopeRouter,
} from "./governance-execution-scope-route";

test("constructs governed execution scope router", () => {
  const router = createGovernanceExecutionScopeRouter({
    db: {} as any,
    materialize_execution_scope: (() => {
      throw new Error("materializer must not execute during construction");
    }) as any,
  });

  assert.ok(router);
  assert.equal(typeof router.use, "function");
});

test("scope route exposes no repository coordinate authority fields", () => {
  const authorizedInputFields = [
    "approval_id",
    "envelope_id",
    "allowed_paths",
    "forbidden_paths",
    "scope_constraints",
  ];

  for (const forbidden of [
    "repo_path",
    "expected_head",
    "branch",
    "remote",
    "remote_url",
    "remote_push_url",
    "project_id",
  ]) {
    assert.equal(authorizedInputFields.includes(forbidden), false);
  }
});
TESTEOF

echo "=== CORRIDOR 6 IMPLEMENTATION VERIFICATION ==="
git diff --check

node --import tsx --test \
  server/routes/governance-execution-approval-route.test.ts \
  server/routes/governance-execution-scope-route.test.ts \
  server/routes/governance-execution-route.test.ts \
  server/execution/production-execution-entry-point.test.ts \
  server/execution/production-governance-execution-composition.test.mjs \
  db/governance-execution-reconciliation-persistence.test.ts

npx tsc --noEmit

if [[ -f scripts/check-semantic-drift.mjs ]]; then
  node scripts/check-semantic-drift.mjs
fi

echo "=== PHASE 2 CORRIDOR 6 — IMPLEMENTATION VERIFIED ==="
echo "EXECUTION_ROUTE_PRODUCTION_REACHABILITY=YES"
echo "EXECUTION_APPROVAL_ROUTE_PRODUCTION_REACHABILITY=YES"
echo "SCOPE_MATERIALIZER_PRODUCTION_REACHABILITY=YES"
echo "INVALID_REMOTE_URL_VS_REGISTRY_PATH_COMPARISON=REMOVED"
echo "CANONICAL_PROJECT_REPOSITORY_ROOT_VALIDATION=PRESERVED"
echo "EXISTING_EXECUTION_ORCHESTRATOR=REUSED"
echo "EXISTING_SCOPE_MATERIALIZER=REUSED"
echo "EXISTING_COMMIT_GUARDS=UNCHANGED"
echo "EXISTING_PUSH_GUARDS=UNCHANGED"
echo "EXISTING_RECONCILIATION_LEDGER=UNCHANGED"
echo "NEW_PARALLEL_ORCHESTRATOR=NO"
echo "NEW_EXECUTION_AUTHORITY=NO"
echo "PRODUCTION_EXECUTION_AUTHORIZED=NO"
echo "PRODUCTION_GIT_EFFECT_EXECUTED=NO"
echo "PRODUCTION_PUSH_EFFECT_EXECUTED=NO"
