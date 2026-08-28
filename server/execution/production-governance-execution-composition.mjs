import sqlite from "../../db/client.ts";
import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";
import { executeGovernedLocalCommit } from "./cade-governed-commit-adapter.ts";
import { executeGovernedRemotePush } from "./cade-governed-push-adapter.ts";
import { createGovernanceExecutionRouter } from "../routes/governance-execution-route.ts";

export const productionGovernanceExecutionDependencies = {
  db: sqlite,
  evaluate_approval: evaluateExecutionApproval,
  execute_commit: executeGovernedLocalCommit,
  execute_push: executeGovernedRemotePush,
};

export function createProductionGovernanceExecutionRouter() {
  return createGovernanceExecutionRouter(
    productionGovernanceExecutionDependencies,
  );
}

export const productionGovernanceExecutionComposition = {
  route_mounted: false,
  production_reachability_authorized: false,
  new_authority_introduced: false,
};
