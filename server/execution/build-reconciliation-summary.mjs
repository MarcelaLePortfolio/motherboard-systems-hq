
export function buildReconciliationSummary({

  envelope,

  executionResult,

  validationResult,

}) {

  return {

    generated_at: new Date().toISOString(),

    envelope_id:

      envelope?.identity?.envelope_id ?? null,

    intent_id:

      envelope?.identity?.intent_id ?? null,

    reconciliation_type:

      envelope?.reconciliation?.reconciliation_type ??

      "diff_based",

    intended_outcome:

      envelope?.execution_plan?.summary ?? null,

    actual_outcome:

      executionResult?.summary ?? null,

    validation: validationResult ?? {

      ok: false,

    },

    execution_trace:

      executionResult?.trace ?? [],

    drift_detected:

      executionResult?.drift_detected ?? false,

  };

}

