
import { validateExecutionEnvelope } from "../guards/validate-execution-envelope.mjs";

import { assertMutationScopeAllowed } from "../guards/mutation-scope-guard.mjs";

import { buildReconciliationSummary } from "./build-reconciliation-summary.mjs";

function normalizeSteps(envelope = {}) {

  const steps = envelope?.execution_plan?.steps;

  return Array.isArray(steps) ? steps : [];

}

function normalizePatches(envelope = {}) {

  const patches = envelope?.patch_spec?.patches;

  return Array.isArray(patches) ? patches : [];

}

function assertDryRunOnly(envelope = {}) {

  if (envelope?.sandbox?.dry_run_required !== true) {

    const err = new Error("Cade engineer adapter currently requires dry-run execution");

    err.code = "CADE_ENGINEER_REQUIRES_DRY_RUN";

    throw err;

  }

  if (envelope?.sandbox?.allow_external_side_effects === true) {

    const err = new Error("Cade engineer adapter refuses external side effects");

    err.code = "CADE_ENGINEER_REFUSES_SIDE_EFFECTS";

    throw err;

  }

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

  const validation = validateExecutionEnvelope(envelope);

  assertDryRunOnly(envelope);

  const steps = normalizeSteps(envelope);

  const patches = normalizePatches(envelope);

  for (const patch of patches) {

    if (patch?.file) {

      assertMutationScopeAllowed(envelope, patch.file);

    }

  }

  for (const step of steps) {

    if (step?.target && typeof step.target === "string") {

      assertMutationScopeAllowed(envelope, step.target);

    }

  }

  const plannedSteps = steps.map(plannedStepSummary);

  const plannedPatches = patches.map(plannedPatchSummary);

  const executionResult = {

    ok: true,

    adapter: "cade_engineer_adapter",

    mode: "dry_run_only",

    summary: envelope?.execution_plan?.summary ?? "Cade engineering plan prepared",

    mutation_performed: false,

    shell_execution_performed: false,

    filesystem_mutation_performed: false,

    planned_steps: plannedSteps,

    planned_patches: plannedPatches,

    trace: [

      {

        event: "envelope_validated",

        ok: true,

      },

      {

        event: "dry_run_enforced",

        ok: true,

      },

      {

        event: "mutation_scope_checked",

        ok: true,

      },

      {

        event: "execution_planned",

        ok: true,

      },

    ],

    drift_detected: false,

  };

  const reconciliation = buildReconciliationSummary({

    envelope,

    executionResult,

    validationResult: validation,

  });

  return {

    ok: true,

    validation,

    execution: executionResult,

    reconciliation,

  };

}

