import sqlite from "../../db/client.ts";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { executeGovernedLocalCommit } from "./cade-governed-commit-adapter.ts";
import { executeGovernedRemotePush } from "./cade-governed-push-adapter.ts";
import { createGovernanceExecutionRouter } from "../routes/governance-execution-route.ts";
import { createGovernanceExecutionApprovalRouter } from "../routes/governance-execution-approval-route.ts";
import { createGovernanceExecutionScopeRouter } from "../routes/governance-execution-scope-route.ts";

export const productionGovernanceExecutionDependencies = {
  db: sqlite,
  evaluate_approval: evaluateExecutionApproval,
  execute_commit: executeGovernedLocalCommit,
  execute_push: executeGovernedRemotePush,
};

export function createProductionGovernanceExecutionRouter() {
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

export const productionGovernanceExecutionComposition = {
  route_mounted: true,
  execution_route_reachable: true,
  execution_approval_route_reachable: true,
  execution_scope_route_reachable: true,
  production_execution_authorized: false,
  new_authority_introduced: false,
};
