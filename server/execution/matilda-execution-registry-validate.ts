import {
  loadCadeExecutionRegistry,
  type CadeExecutionState,
} from "./matilda-execution-registry-loader";

type State = CadeExecutionState;

export function validateExecutionRegistry() {
  const registry = loadCadeExecutionRegistry();
  const transitions = registry.execution_state_model.transitions;
  const states = registry.execution_state_model.states;

  for (const from of Object.keys(transitions) as State[]) {
    if (!states.includes(from)) {
      throw new Error(
        `Invalid registry: unknown state '${from}' in transitions`,
      );
    }

    for (const to of transitions[from]) {
      if (!states.includes(to)) {
        throw new Error(
          `Invalid registry: unknown transition target '${to}'`,
        );
      }
    }
  }

  if (transitions.EXECUTABLE.length > 0) {
    throw new Error(
      "Invalid registry: EXECUTABLE must be terminal state",
    );
  }

  return {
    ok: true,
    validatedStates: states.length,
  };
}
