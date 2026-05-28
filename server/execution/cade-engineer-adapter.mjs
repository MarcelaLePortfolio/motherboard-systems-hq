
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

import { buildReconciliationSummary } from "./build-reconciliation-summary.mjs";

function normalizeSteps(envelope = {}) {

  const steps = envelope?.execution_plan?.steps;

  return Array.isArray(steps) ? steps : [];

}

function normalizePatches(envelope = {}) {

  const patches = envelope?.patch_spec?.patches;

  return Array.isArray(patches) ? patches : [];

}

function plannedStepSummary(step = {}) {

  return {

    step_id: step?.step_id ?? null,

    action: step?.action ?? null,

    target: step?.target ?? null,

    instructions: step?.instructions ?? null,

    expected_output: step?.expected_output ?? null,

    execution_mode: "dry_run_only",

    mutation_performed: false,

  };

}

function plannedPatchSummary(patch = {}) {

  return {

    file: patch?.file ?? null,

    operation: patch?.operation ?? null,

    format: "planned_only",

    mutation_performed: false,

  };

}

export function planCadeEngineeringExecution(envelope = {}) {

  const governance = validateGovernedExecutionEnvelope(envelope);

  const steps = normalizeSteps(envelope);

  const patches = normalizePatches(envelope);

  const plannedSteps = steps.map(plannedStepSummary);

  const plannedPatches = patches.map(plannedPatchSummary);

  const executionResult = {

    ok: true,

    adapter: "cade_engineer_adapter",

    governance_validator: governance.validator,

    mode: "dry_run_only",

    summary: envelope?.execution_plan?.summary ?? "Cade engineering plan prepared",

    mutation_performed: false,

    shell_execution_performed: false,

    filesystem_mutation_performed: false,

    planned_steps: plannedSteps,

    planned_patches: plannedPatches,

    trace: [

      ...governance.trace,

      {

        event: "cade_engineering_plan_generated",

        ok: true,

      },

    ],

    drift_detected: false,

  };

  const reconciliation = buildReconciliationSummary({

    envelope,

    executionResult,

    validationResult: governance,

  });

  return {

    ok: true,

    governance,

    execution: executionResult,

    reconciliation,

  };

}

