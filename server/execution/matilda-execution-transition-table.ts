import {
  loadCadeExecutionRegistry,
  type CadeExecutionState,
} from "./matilda-execution-registry-loader";

type State = CadeExecutionState;

export function buildTransitionTable(): Record<State, State[]> {
  const registry = loadCadeExecutionRegistry();

  return registry.execution_state_model.transitions;
}
