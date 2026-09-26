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
  const downstream_authorized =
    input.preview_confirmed && input.plan_review_ready;

  const scheduler_authorized = downstream_authorized;
  const routing_authorized = downstream_authorized;
  const worker_claim_authorized = downstream_authorized;
  const orchestration_authorized = downstream_authorized;
  const execution_authorized = downstream_authorized;

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
