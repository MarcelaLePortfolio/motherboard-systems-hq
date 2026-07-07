
import { loadCadeExecutionRegistry } from "./matilda-execution-registry-loader";

type State = "DISABLED" | "ARMED" | "READY" | "EXECUTABLE";

export function buildTransitionTable(): Record<State, State[]> {

  const registry = loadCadeExecutionRegistry();

  return {} as Record<State, State[]>;

}

