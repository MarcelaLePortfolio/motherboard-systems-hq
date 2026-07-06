
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

type State = string;

export function validateExecutionRegistry() {

  const registry = loadCadeExecutionRegistry();

  const transitions = registry.execution_state_model.transitions as Record<State, State[]>;

  const states = registry.execution_state_model.states;

  // 1. Ensure all transition nodes exist in declared state set

  for (const from of Object.keys(transitions)) {

    if (!states.includes(from)) {

      throw new Error(`Invalid registry: unknown state '${from}' in transitions`);

    }

    for (const to of transitions[from]) {

      if (!states.includes(to)) {

        throw new Error(`Invalid registry: unknown transition target '${to}'`);

      }

    }

  }

  // 2. Ensure EXECUTABLE is terminal (enforced invariant)

  if (transitions["EXECUTABLE"]?.length > 0) {

    throw new Error("Invalid registry: EXECUTABLE must be terminal state");

  }

  return {

    ok: true,

    validatedStates: states.length,

  };

}

