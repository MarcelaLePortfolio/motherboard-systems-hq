
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

type State = "DISABLED" | "ARMED" | "READY" | "EXECUTABLE";

export function buildTransitionTable(): Record<State, State[]> {

  const registry = loadCadeExecutionRegistry();

  return registry.execution_state_model.transitions as Record<State, State[]>;

}

