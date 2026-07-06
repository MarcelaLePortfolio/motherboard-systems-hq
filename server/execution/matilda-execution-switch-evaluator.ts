
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

export type ExecutionSwitchInput = {

  execution_authorized: boolean;

  preview_confirmed: boolean;

  execution_plan_status: string;

  confirmation_result?: string;

};

type State = "DISABLED" | "ARMED" | "READY" | "EXECUTABLE";

export function evaluateExecutionSwitch(input: ExecutionSwitchInput) {

  const registry = loadCadeExecutionRegistry();

  const allowedStates = registry.execution_state_model.states as State[];

  const isPlanReady =

    input.execution_plan_status === "plan_review_ready" &&

    registry.execution_state_model.final_state_is_derived_only === true;

  const isArmed = input.execution_authorized === true;

  const isReady = isArmed && input.preview_confirmed === true;

  const isExecutable = isReady && isPlanReady;

  const nextState: State = isExecutable

    ? "EXECUTABLE"

    : isReady

    ? "READY"

    : isArmed

    ? "ARMED"

    : "DISABLED";

  if (!allowedStates.includes(nextState)) {

    throw new Error(

      `Invalid execution state derived from registry contract: ${nextState}`

    );

  }

  return {

    state: nextState,

    isExecutable,

    registry_bound: true,

  };

}

