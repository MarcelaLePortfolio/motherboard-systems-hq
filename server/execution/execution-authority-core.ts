
export type ExecutionRequest = {

  preview_confirmed: boolean;

  plan_review_ready: boolean;

  shell_requested?: boolean;

};

export type ExecutionDecision = {

  execution_authorized: boolean;

  reason: string;

};

export function evaluateExecutionAuthority(

  input: ExecutionRequest

): ExecutionDecision {

  if (!input.preview_confirmed) {

    return {

      execution_authorized: false,

      reason: "Preview not confirmed"

    };

  }

  if (!input.plan_review_ready) {

    return {

      execution_authorized: false,

      reason: "Plan not ready"

    };

  }

  return {

    execution_authorized: true,

    reason: "All gates satisfied"

  };

}

