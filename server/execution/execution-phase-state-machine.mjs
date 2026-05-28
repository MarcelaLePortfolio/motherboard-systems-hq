
const VALID_PHASES = [

  "intent_normalized",

  "envelope_drafted",

  "governance_validated",

  "approval_gated",

  "planning_completed",

  "mutation_authorized",

  "execution_completed",

  "reconciliation_completed",

  "failed_closed",

];

const VALID_TRANSITIONS = {

  intent_normalized: [

    "envelope_drafted",

    "failed_closed",

  ],

  envelope_drafted: [

    "governance_validated",

    "failed_closed",

  ],

  governance_validated: [

    "approval_gated",

    "failed_closed",

  ],

  approval_gated: [

    "planning_completed",

    "mutation_authorized",

    "failed_closed",

  ],

  planning_completed: [

    "failed_closed",

  ],

  mutation_authorized: [

    "execution_completed",

    "failed_closed",

  ],

  execution_completed: [

    "reconciliation_completed",

    "failed_closed",

  ],

  reconciliation_completed: [],

  failed_closed: [],

};

function invariant(condition, message, code = "EXECUTION_PHASE_STATE_ERROR") {

  if (!condition) {

    const err = new Error(message);

    err.code = code;

    throw err;

  }

}

export function buildExecutionStateMachine() {

  return {

    machine: "canonical_execution_phase_state_machine",

    phases: VALID_PHASES,

    transitions: VALID_TRANSITIONS,

  };

}

export function validateExecutionPhaseTransition({

  from,

  to,

}) {

  invariant(

    VALID_PHASES.includes(from),

    `unknown phase: ${from}`,

  );

  invariant(

    VALID_PHASES.includes(to),

    `unknown phase: ${to}`,

  );

  const allowed = VALID_TRANSITIONS[from] || [];

  invariant(

    allowed.includes(to),

    `invalid phase transition: ${from} -> ${to}`,

    "INVALID_EXECUTION_PHASE_TRANSITION",

  );

  return {

    ok: true,

    from,

    to,

    allowed: true,

    trace: [

      {

        event: "phase_transition_validated",

        ok: true,

      },

    ],

  };

}

export function getExecutionPhaseCapabilities(phase) {

  invariant(

    VALID_PHASES.includes(phase),

    `unknown phase: ${phase}`,

  );

  return {

    phase,

    planning_allowed: [

      "intent_normalized",

      "envelope_drafted",

      "governance_validated",

      "approval_gated",

      "planning_completed",

    ].includes(phase),

    mutation_allowed: [

      "mutation_authorized",

      "execution_completed",

      "reconciliation_completed",

    ].includes(phase),

    shell_execution_allowed: false,

    autonomous_execution_allowed: false,

    fail_closed_required: true,

  };

}

