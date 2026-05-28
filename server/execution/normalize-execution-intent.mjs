
function fail(code, message) {

  const err = new Error(message);

  err.code = code;

  throw err;

}

function normalizeText(value) {

  return String(value || "").trim();

}

export function normalizeExecutionIntent(intent = {}) {

  const actor = normalizeText(intent.actor || "Matilda");

  const target = normalizeText(intent.target || "Cade");

  const objective = normalizeText(intent.objective);

  const requestedOutcome = normalizeText(intent.requested_outcome);

  if (!objective) {

    fail(

      "MISSING_EXECUTION_OBJECTIVE",

      "execution intent requires objective",

    );

  }

  if (!requestedOutcome) {

    fail(

      "MISSING_REQUESTED_OUTCOME",

      "execution intent requires requested outcome",

    );

  }

  const normalized = {

    intent_id: intent.intent_id || `intent-${Date.now()}`,

    actor,

    target,

    objective,

    requested_outcome: requestedOutcome,

    execution_mode: {

      planning_only: true,

      mutation_allowed: false,

      shell_execution_allowed: false,

      autonomous_execution_allowed: false,

    },

    governance_profile: {

      requires_delegation: true,

      requires_validation: true,

      requires_reconciliation: true,

      requires_approval_gate: true,

    },

    metadata: {

      source: intent.source || "chat_interpretation",

      normalized_at: new Date().toISOString(),

      tags: Array.isArray(intent.tags) ? intent.tags : [],

    },

  };

  return {

    ok: true,

    normalized_intent: normalized,

    trace: [

      {

        event: "execution_intent_normalized",

        ok: true,

      },

      {

        event: "planning_only_mode_enforced",

        ok: true,

      },

      {

        event: "execution_authority_removed",

        ok: true,

      },

    ],

  };

}

