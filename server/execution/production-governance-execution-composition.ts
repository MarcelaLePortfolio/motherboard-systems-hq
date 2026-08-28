import sqlite from "../../db/client";
import {
  evaluateExecutionApproval,
} from "./execution-approval-gate";
import {
  executeGovernedLocalCommit,
} from "./cade-governed-commit-adapter";
import {
  executeGovernedRemotePush,
} from "./cade-governed-push-adapter";
import {
  createGovernanceExecutionRouter,
} from "../routes/governance-execution-route";

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
