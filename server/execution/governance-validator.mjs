
import { validateExecutionEnvelope } from "../guards/validate-execution-envelope.mjs";

import { assertMutationScopeAllowed } from "../guards/mutation-scope-guard.mjs";

function fail(code, message) {

  const err = new Error(message);

  err.code = code;

  throw err;

}

function normalizeSteps(envelope = {}) {

  const steps = envelope?.execution_plan?.steps;

  return Array.isArray(steps) ? steps : [];

}

function normalizePatches(envelope = {}) {

  const patches = envelope?.patch_spec?.patches;

  return Array.isArray(patches) ? patches : [];

}

function assertDryRunGovernance(envelope = {}) {

  if (envelope?.sandbox?.dry_run_required !== true) {

    fail(

      "GOVERNANCE_REQUIRES_DRY_RUN",

      "governance validator requires sandbox dry_run_required=true",

    );

  }

  if (envelope?.sandbox?.allow_external_side_effects === true) {

    fail(

      "GOVERNANCE_REFUSES_EXTERNAL_SIDE_EFFECTS",

      "governance validator refuses external side effects",

    );

  }

}

function assertNoExecutionEscalation(envelope = {}) {

  const mode = envelope?.execution_mode ?? {};

  if (mode?.mutation_allowed === true) {

    fail(

      "GOVERNANCE_REFUSES_MUTATION_AUTHORITY",

      "current governance phase refuses mutation authority",

    );

  }

  if (mode?.shell_execution_allowed === true) {

    fail(

      "GOVERNANCE_REFUSES_SHELL_EXECUTION",

      "current governance phase refuses shell execution",

    );

  }

  if (mode?.autonomous_execution_allowed === true) {

    fail(

      "GOVERNANCE_REFUSES_AUTONOMOUS_EXECUTION",

      "current governance phase refuses autonomous execution",

    );

  }

}

function assertScopedTargets(envelope = {}) {

  const checked = [];

  for (const patch of normalizePatches(envelope)) {

    if (patch?.file) {

      assertMutationScopeAllowed(envelope, patch.file);

      checked.push({

        kind: "patch",

        path: patch.file,

        allowed: true,

      });

    }

  }

  for (const step of normalizeSteps(envelope)) {

    if (step?.target && typeof step.target === "string") {

      assertMutationScopeAllowed(envelope, step.target);

      checked.push({

        kind: "step",

        path: step.target,

        allowed: true,

      });

    }

  }

  return checked;

}

export function validateGovernedExecutionEnvelope(envelope = {}) {

  const structural = validateExecutionEnvelope(envelope);

  assertDryRunGovernance(envelope);

  assertNoExecutionEscalation(envelope);

  const scoped_targets = assertScopedTargets(envelope);

  return {

    ok: true,

    validator: "canonical_governance_validator",

    mode: "dry_run_only",

    validated_at: new Date().toISOString(),

    structural,

    delegated: envelope?.delegation_authorization?.state === "delegated",

    reconciliation_required: envelope?.reconciliation?.required === true,

    rollback_supported: envelope?.rollback_contract?.rollback_supported === true,

    mutation_allowed: false,

    shell_execution_allowed: false,

    autonomous_execution_allowed: false,

    scoped_targets,

    trace: [

      {

        event: "structural_envelope_validation",

        ok: true,

      },

      {

        event: "dry_run_governance_enforced",

        ok: true,

      },

      {

        event: "execution_escalation_refused",

        ok: true,

      },

      {

        event: "mutation_scope_validated",

        ok: true,

      },

    ],

  };

}

