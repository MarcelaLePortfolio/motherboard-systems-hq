
function nowIso() {

  return new Date().toISOString();

}

export function normalizeGovernedResponse({

  ok = false,

  phase = "unknown",

  envelope_version = null,

  governance_ok = false,

  approval_gate_ok = false,

  cade_plan_ok = false,

  mutation_performed = false,

  shell_execution_performed = false,

  autonomous_execution_performed = false,

  trace = [],

  error = null,

} = {}) {

  return {

    response_schema:

      "governed_planning_response.v1",

    normalized_at:

      nowIso(),

    ok,

    phase,

    envelope_version,

    governance: {

      ok: governance_ok,

    },

    approval_gate: {

      ok: approval_gate_ok,

    },

    cade_planning: {

      ok: cade_plan_ok,

    },

    execution_authority: {

      mutation_performed,

      shell_execution_performed,

      autonomous_execution_performed,

    },

    trace: Array.isArray(trace)

      ? trace

      : [],

    error:

      error || null,

  };

}

