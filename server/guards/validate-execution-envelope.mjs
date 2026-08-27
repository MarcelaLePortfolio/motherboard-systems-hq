
import {

  EXECUTION_ENVELOPE_VERSION,

  WORKSPACE_TYPES,

  SCOPE_TYPES,

  APPROVAL_STATES,

} from "../contracts/execution-envelope.v1.mjs";

function invariant(condition, message) {

  if (!condition) {

    const err = new Error(message);

    err.code = "EXECUTION_ENVELOPE_VALIDATION_FAILED";

    throw err;

  }

}

export function validateExecutionEnvelope(envelope = {}) {

  invariant(

    envelope?.envelope_version === EXECUTION_ENVELOPE_VERSION,

    "invalid envelope_version",

  );

  invariant(

    envelope?.identity?.origin === "matilda",

    "origin must be matilda",

  );

  invariant(

    envelope?.identity?.target === "cade",

    "target must be cade",

  );

  invariant(

    WORKSPACE_TYPES.includes(

      envelope?.project_target?.workspace_type,

    ),

    "invalid workspace_type",

  );

  const expectedHead = envelope?.project_target?.expected_head;

  invariant(
    expectedHead === undefined ||
      expectedHead === null ||
      (
        typeof expectedHead === "string" &&
        /^[0-9a-f]{40}$/i.test(expectedHead)
      ),
    "project_target.expected_head must be a 40-character git commit SHA when supplied",
  );

  invariant(

    SCOPE_TYPES.includes(

      envelope?.mutation_scope?.scope_type,

    ),

    "invalid scope_type",

  );

  invariant(

    Array.isArray(

      envelope?.mutation_scope?.allowed_paths,

    ) &&

      envelope.mutation_scope.allowed_paths.length > 0,

    "allowed_paths required",

  );

  invariant(

    Array.isArray(

      envelope?.mutation_scope?.forbidden_paths,

    ),

    "forbidden_paths must be array",

  );

  invariant(

    Array.isArray(

      envelope?.execution_plan?.steps,

    ) &&

      envelope.execution_plan.steps.length > 0,

    "execution steps required",

  );

  invariant(

    envelope?.rollback_contract?.rollback_supported === true,

    "rollback support required",

  );

  invariant(

    Array.isArray(

      envelope?.validation_contract?.success_criteria,

    ),

    "success_criteria required",

  );

  invariant(

    APPROVAL_STATES.includes(

      envelope?.delegation_authorization?.state,

    ),

    "invalid delegation authorization state",

  );

  invariant(

    envelope?.delegation_authorization?.state ===

      "delegated",

    "execution not delegated",

  );

  if (

    envelope?.project_target?.workspace_type ===

    "motherboard_systems"

  ) {

    invariant(

      envelope?.sandbox?.dry_run_required === true,

      "motherboard_systems requires sandbox dry run",

    );

    invariant(

      envelope?.reconciliation?.required === true,

      "motherboard_systems requires reconciliation",

    );

  }

  return {

    ok: true,

    validated_at: new Date().toISOString(),

  };

}

