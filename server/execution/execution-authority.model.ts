
export type ExecutionAuthoritySnapshot = {

  execution_authorized: boolean;

  scheduler_authorized: boolean;

  routing_authorized: boolean;

  worker_claim_authorized: boolean;

  orchestration_authorized: boolean;

  source: "execution-authority-core";

  reason: string;

};

