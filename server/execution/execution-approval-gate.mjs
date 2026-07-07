import { evaluateExecutionSwitch } from "./matilda-execution-switch-evaluator.js";

function fail(code, message) {

  const err = new Error(message);

  err.code = code;

  throw err;

}

function normalizeApproval(approval = {}) {

  return {

    approval_id: approval?.approval_id ?? null,

    approved_by: approval?.approved_by ?? null,

    approval_scope: approval?.approval_scope ?? "none",

    mutation_authorized: approval?.mutation_authorized === true,

    shell_execution_authorized: approval?.shell_execution_authorized === true,

    autonomous_execution_authorized:

      approval?.autonomous_execution_authorized === true,

    issued_at: approval?.issued_at ?? null,

    expires_at: approval?.expires_at ?? null,

    justification: approval?.justification ?? null,

  };

}

export function evaluateExecutionApproval({

  envelope = {},

  governance = {},

  approval = {},

} = {}) {

  const normalized = normalizeApproval(approval);

  if (!governance?.ok) {

    fail(

      "GOVERNANCE_VALIDATION_REQUIRED",

      "approval gate requires successful governance validation",

    );

  }

  if (normalized.mutation_authorized === true) {

    fail(

      "MUTATION_AUTHORITY_DISABLED",

      "mutation authority remains disabled in current execution phase",

    );

  }

  if (normalized.shell_execution_authorized === true) {

    fail(

      "SHELL_AUTHORITY_DISABLED",

      "shell execution authority remains disabled in current execution phase",

    );

  }

  if (normalized.autonomous_execution_authorized === true) {

    fail(

      "AUTONOMOUS_AUTHORITY_DISABLED",

      "autonomous execution authority remains disabled in current execution phase",

    );

  }

  return {

    ok: true,

    approval_gate: "canonical_execution_approval_gate",

    execution_phase: "governed_planning_only",

    delegated: envelope?.delegation_authorization?.state === "delegated",

    approval_present: normalized.approval_id !== null,

    mutation_authorized: false,

    shell_execution_authorized: false,

    autonomous_execution_authorized: false,

    approval_artifact: normalized,

    trace: [

      {

        event: "approval_artifact_normalized",

        ok: true,

      },

      {

        event: "mutation_authority_blocked",

        ok: true,

      },

      {

        event: "shell_authority_blocked",

        ok: true,

      },

      {

        event: "autonomous_authority_blocked",

        ok: true,

      },

    ],

  };

}

