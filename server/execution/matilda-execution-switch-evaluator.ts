
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

export type ExecutionSwitchInput = {

  execution_authorized: boolean;

  preview_confirmed: boolean;

  execution_plan_status: string;

  confirmation_result?: string;

};

export function evaluateExecutionSwitch(input: ExecutionSwitchInput) {

  const registry = loadCadeExecutionRegistry();

  const isExecutable =

    input.execution_authorized === true &&

    input.preview_confirmed === true &&

    input.execution_plan_status === "plan_review_ready" &&

    registry.execution_state_model.final_state_is_derived_only === true;

  let state: "DISABLED" | "ARMED" | "READY" | "EXECUTABLE" = "DISABLED";

  if (input.execution_authorized) state = "ARMED";

  if (input.preview_confirmed) state = "READY";

  if (isExecutable) state = "EXECUTABLE";

  return {

    state,

    isExecutable,

    registry_bound: true,

  };

}

