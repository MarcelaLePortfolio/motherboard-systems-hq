
import { evaluateExecutionAuthority } from "./execution-authority-core";

import { ExecutionAuthoritySnapshot } from "./execution-authority.model";

export function buildExecutionAuthoritySnapshot(input: any): ExecutionAuthoritySnapshot {

  const result = evaluateExecutionAuthority(input);

  return {

    execution_authorized: result.execution_authorized,

    scheduler_authorized: result.scheduler_authorized,

    routing_authorized: result.routing_authorized,

    worker_claim_authorized: result.worker_claim_authorized,

    orchestration_authorized: result.orchestration_authorized,

    source: "execution-authority-core",

    reason: result.reason

  };

}

