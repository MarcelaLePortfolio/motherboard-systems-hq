
function nowIso() {

  return new Date().toISOString();

}

export function normalizeReconciliationArtifact({

  envelope_version = null,

  phase = "planning_only",

  governance_ok = false,

  approval_gate_ok = false,

  cade_plan_ok = false,

  mutation_performed = false,

  shell_execution_performed = false,

  autonomous_execution_performed = false,

  trace = [],

  reconciliation_entries = [],

} = {}) {

  return {

    reconciliation_schema:

      "governed_reconciliation_artifact.v1",

    generated_at:

      nowIso(),

    envelope_version,

    phase,

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

    reconciliation_entries:

      Array.isArray(reconciliation_entries)

        ? reconciliation_entries

        : [],

    trace:

      Array.isArray(trace)

        ? trace

        : [],

  };

}

