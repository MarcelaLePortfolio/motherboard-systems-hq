
import {

  buildExecutionStateMachine,

  validateExecutionPhaseTransition,

  getExecutionPhaseCapabilities,

} from "./execution-phase-state-machine.mjs";

const machine = buildExecutionStateMachine();

const transition = validateExecutionPhaseTransition({

  from: "approval_gated",

  to: "planning_completed",

});

const capabilities = getExecutionPhaseCapabilities(

  "planning_completed",

);

console.log(JSON.stringify({

  ok: true,

  machine: machine.machine,

  transition_ok: transition.ok,

  planning_allowed: capabilities.planning_allowed,

  mutation_allowed: capabilities.mutation_allowed,

  shell_execution_allowed: capabilities.shell_execution_allowed,

  autonomous_execution_allowed: capabilities.autonomous_execution_allowed,

}, null, 2));

