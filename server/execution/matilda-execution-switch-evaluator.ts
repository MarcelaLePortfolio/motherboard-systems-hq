
export type ExecutionSwitchInput = {

  execution_authorized: boolean;

  preview_confirmed: boolean;

  execution_plan_status: string;

  confirmation_result: string;

  ambiguity_findings?: string[];

};

export function evaluateExecutionSwitch(input: ExecutionSwitchInput) {

  const hasAmbiguity =

    (input.ambiguity_findings ?? []).length > 0;

  const isExecutable =

    input.execution_authorized === true &&

    input.preview_confirmed === true &&

    input.execution_plan_status === "plan_review_ready" &&

    input.confirmation_result === "confirmed" &&

    !hasAmbiguity;

  let state: "DISABLED" | "ARMED" | "READY" | "EXECUTABLE" = "DISABLED";

  if (input.execution_authorized) state = "ARMED";

  if (input.preview_confirmed) state = "READY";

  if (isExecutable) state = "EXECUTABLE";

  return {

    state,

    isExecutable,

    derived: true

  };

}

