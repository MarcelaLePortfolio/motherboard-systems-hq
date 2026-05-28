
function nowIso() {

  return new Date().toISOString();

}

function normalizeTrace(trace) {

  if (!Array.isArray(trace)) {

    return [];

  }

  return trace.map((entry, index) => ({

    sequence: index + 1,

    event: entry?.event || "unknown_event",

    ok: Boolean(entry?.ok),

    recorded_at: nowIso(),

  }));

}

export function buildGovernanceAuditLedger({

  envelope_version = null,

  phase = "planning_only",

  governance_ok = false,

  approval_gate_ok = false,

  cade_plan_ok = false,

  reconciliation_schema = null,

  mutation_performed = false,

  shell_execution_performed = false,

  autonomous_execution_performed = false,

  trace = [],

} = {}) {

  return {

    ledger_schema:

      "governed_execution_audit_ledger.v1",

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

    reconciliation: {

      schema:

        reconciliation_schema,

    },

    execution_authority: {

      mutation_performed,

      shell_execution_performed,

      autonomous_execution_performed,

    },

    audit_trace:

      normalizeTrace(trace),

    immutable_constraints: {

      append_only: true,

      mutation_authority_granted: false,

      shell_authority_granted: false,

      autonomous_authority_granted: false,

    },

  };

}

