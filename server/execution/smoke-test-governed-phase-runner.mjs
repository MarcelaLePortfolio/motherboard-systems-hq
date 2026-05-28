
import {

  createGovernedPhaseRunner,

  runGovernedPlanningPhases,

} from "./governed-phase-runner.mjs";

const runner = createGovernedPhaseRunner();

const result = runGovernedPlanningPhases({

  initial_phase: "intent_normalized",

  phases: [

    "envelope_drafted",

    "governance_validated",

    "approval_gated",

    "planning_completed",

  ],

});

console.log(JSON.stringify({

  ok: result.ok,

  runner: runner.runner,

  final_phase: result.final_phase,

  mutation_performed: result.mutation_performed,

  shell_execution_performed: result.shell_execution_performed,

  autonomous_execution_performed: result.autonomous_execution_performed,

  trace: result.trace,

}, null, 2));

