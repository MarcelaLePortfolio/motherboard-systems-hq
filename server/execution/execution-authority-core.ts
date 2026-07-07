
export type ExecutionAuthorityState = {

  execution_authorized: boolean;

  scheduler_authorized: boolean;

  routing_authorized: boolean;

  worker_claim_authorized: boolean;

  orchestration_authorized: boolean;

  preview_confirmed: boolean;

  plan_review_ready: boolean;

  source: "execution-authority-core";

  reason: string;

};

export type ExecutionRequest = {

  preview_confirmed: boolean;

  plan_review_ready: boolean;

};

export function evaluateExecutionAuthority(

  input: ExecutionRequest

): ExecutionAuthorityState {

  const scheduler_authorized = input.plan_review_ready;

  const routing_authorized = input.plan_review_ready;

  const worker_claim_authorized = input.plan_review_ready;

  const orchestration_authorized = input.plan_review_ready;

  const execution_authorized =

    input.preview_confirmed && input.plan_review_ready;

  if (!input.preview_confirmed) {

    return {

      execution_authorized: false,

      scheduler_authorized,

      routing_authorized,

      worker_claim_authorized,

      orchestration_authorized,

      preview_confirmed: input.preview_confirmed,

      plan_review_ready: input.plan_review_ready,

      source: "execution-authority-core",

      reason: "Preview not confirmed"

    };

  }

  if (!input.plan_review_ready) {

    return {

      execution_authorized: false,

      scheduler_authorized,

      routing_authorized,

      worker_claim_authorized,

      orchestration_authorized,

      preview_confirmed: input.preview_confirmed,

      plan_review_ready: input.plan_review_ready,

      source: "execution-authority-core",

      reason: "Plan not ready"

    };

  }

  return {

    execution_authorized,

    scheduler_authorized,

    routing_authorized,

    worker_claim_authorized,

    orchestration_authorized,

    preview_confirmed: input.preview_confirmed,

    plan_review_ready: input.plan_review_ready,

    source: "execution-authority-core",

    reason: "All gates satisfied"

  };

}

