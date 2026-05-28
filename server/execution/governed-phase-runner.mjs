
import {

  validateExecutionPhaseTransition,

  getExecutionPhaseCapabilities,

} from "./execution-phase-state-machine.mjs";

export function createGovernedPhaseRunner() {

  return {

    runner: "governed_phase_runner",

    mode: "planning_only",

  };

}

export function runGovernedPlanningPhases({

  initial_phase = "intent_normalized",

  phases = [],

}) {

  let currentPhase = initial_phase;

  const trace = [];

  for (const nextPhase of phases) {

    const transition = validateExecutionPhaseTransition({

      from: currentPhase,

      to: nextPhase,

    });

    const capabilities = getExecutionPhaseCapabilities(

      nextPhase,

    );

    trace.push({

      event: "phase_transition_completed",

      from: currentPhase,

      to: nextPhase,

      planning_allowed: capabilities.planning_allowed,

      mutation_allowed: capabilities.mutation_allowed,

      shell_execution_allowed: capabilities.shell_execution_allowed,

      autonomous_execution_allowed: capabilities.autonomous_execution_allowed,

      ok: transition.ok,

    });

    currentPhase = nextPhase;

  }

  return {

    ok: true,

    runner: "governed_phase_runner",

    final_phase: currentPhase,

    mutation_performed: false,

    shell_execution_performed: false,

    autonomous_execution_performed: false,

    trace,

  };

}

