
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

export type State = "DISABLED" | "ARMED" | "READY" | "EXECUTABLE";

export type ExecutionSwitchInput = {

  current_state: State;

  execution_authorized: boolean;

  preview_confirmed: boolean;

  execution_plan_status: string;

  confirmation_result?: string;

};

export function evaluateExecutionSwitch(input: ExecutionSwitchInput) {

  const registry = loadCadeExecutionRegistry();

  const transitions = registry.execution_state_model.transitions as Record<State, State[]>;

  const isPlanReady =

    input.execution_plan_status === "plan_review_ready" &&

    registry.execution_state_model.final_state_is_derived_only === true;

  const isArmed = input.execution_authorized === true;

  const isReady = isArmed && input.preview_confirmed === true;

  const candidateState: State = isReady

    ? "READY"

    : isArmed

    ? "ARMED"

    : "DISABLED";

  const nextState: State = isPlanReady && candidateState === "READY"

    ? "EXECUTABLE"

    : candidateState;

  const allowed = transitions[input.current_state] || [];

  if (!allowed.includes(nextState) && nextState !== input.current_state) {

    throw new Error(

      `Invalid state transition: ${input.current_state} -> ${nextState}`

    );

  }

  return {

    state: nextState,

    isExecutable: nextState === "EXECUTABLE",

    registry_bound: true

  };

}

