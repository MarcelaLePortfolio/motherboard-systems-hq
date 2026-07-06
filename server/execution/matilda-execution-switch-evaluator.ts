
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

export type ExecutionSwitchInput = {

  execution_authorized: boolean;

  preview_confirmed: boolean;

  execution_plan_status: string;

  confirmation_result?: string;

};

export function evaluateExecutionSwitch(input: ExecutionSwitchInput) {

  const registry = loadCadeExecutionRegistry();

  const isPlanReady =

    input.execution_plan_status === "plan_review_ready" &&

    registry.execution_state_model.final_state_is_derived_only === true;

  const isArmed = input.execution_authorized === true;

  const isReady = isArmed && input.preview_confirmed === true;

  const isExecutable = isReady && isPlanReady;

  const state: "DISABLED" | "ARMED" | "READY" | "EXECUTABLE" =

    isExecutable

      ? "EXECUTABLE"

      : isReady

      ? "READY"

      : isArmed

      ? "ARMED"

      : "DISABLED";

  return {

    state,

    isExecutable,

    registry_bound: true,

  };

}

