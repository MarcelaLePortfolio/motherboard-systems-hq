import {
  loadCadeExecutionRegistry,
  type CadeExecutionState,
} from "./matilda-execution-registry-loader";

export type State = CadeExecutionState;

export type ExecutionSwitchInput = {
  current_state: State;
  execution_authorized: boolean;
  preview_confirmed: boolean;
  execution_plan_status: string;
  confirmation_result?: string;
};

export function evaluateExecutionSwitch(input: ExecutionSwitchInput) {
  const registry = loadCadeExecutionRegistry();
  const transitions = registry.execution_state_model.transitions;

  const isPlanReady =
    input.execution_plan_status === "plan_review_ready" &&
    registry.execution_state_model.final_state_is_derived_only === true;

  const allowed = transitions[input.current_state] || [];
  const possible: State[] = [];

  if (
    input.execution_authorized &&
    allowed.includes("ARMED")
  ) {
    possible.push("ARMED");
  }

  if (
    input.execution_authorized &&
    input.preview_confirmed &&
    allowed.includes("READY")
  ) {
    possible.push("READY");
  }

  if (
    isPlanReady &&
    allowed.includes("EXECUTABLE")
  ) {
    possible.push("EXECUTABLE");
  }

  const nextState: State =
    possible.includes("EXECUTABLE")
      ? "EXECUTABLE"
      : possible.includes("READY")
        ? "READY"
        : possible.includes("ARMED")
          ? "ARMED"
          : input.current_state;

  if (
    !allowed.includes(nextState) &&
    nextState !== input.current_state
  ) {
    throw new Error(
      `Invalid state transition: ${input.current_state} -> ${nextState}`,
    );
  }

  return {
    state: nextState,
    isExecutable: nextState === "EXECUTABLE",
    registry_bound: true,
  };
}
