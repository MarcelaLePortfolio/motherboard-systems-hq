
export const EXECUTION_ENVELOPE_VERSION = "matilda.cade.exec.v1";

export const WORKSPACE_TYPES = [

  "motherboard_systems",

  "client_repo",

  "sandbox",

  "unknown",

];

export const SCOPE_TYPES = [

  "file",

  "module",

  "service",

  "repo",

  "multi_repo",

];

export const APPROVAL_STATES = [

  "delegated",

  "rejected",

  "conditional",

  "pending",

];

export const EXECUTION_ACTIONS = [

  "create",

  "modify",

  "delete",

  "refactor",

  "test",

  "run",

  "inspect",

];

export function createExecutionEnvelope(input = {}) {

  return {

    envelope_version: EXECUTION_ENVELOPE_VERSION,

    identity: {

      envelope_id: input?.identity?.envelope_id ?? null,

      intent_id: input?.identity?.intent_id ?? null,

      timestamp: input?.identity?.timestamp ?? new Date().toISOString(),

      origin: "matilda",

      target: "cade",

    },

    intent: {

      raw_user_intent: input?.intent?.raw_user_intent ?? "",

      normalized_intent: input?.intent?.normalized_intent ?? "",

      intent_type: input?.intent?.intent_type ?? "other",

      intent_evidence: input?.intent?.intent_evidence ?? [],

      confidence_score: input?.intent?.confidence_score ?? 0,

      confidence_score_authority: "non_authoritative_metadata",

    },

    project_target: {

      project_name: input?.project_target?.project_name ?? "",

      repo_url: input?.project_target?.repo_url ?? "",

      repo_path: input?.project_target?.repo_path ?? "",

      branch: input?.project_target?.branch ?? "",
      expected_head: input?.project_target?.expected_head ?? null,

      workspace_type:

        input?.project_target?.workspace_type ?? "unknown",

    },

    mutation_scope: {

      scope_type: input?.mutation_scope?.scope_type ?? "file",

      allowed_paths: input?.mutation_scope?.allowed_paths ?? [],

      forbidden_paths: input?.mutation_scope?.forbidden_paths ?? [],

      scope_constraints:

        input?.mutation_scope?.scope_constraints ?? "",

    },

    execution_plan: {

      summary: input?.execution_plan?.summary ?? "",

      steps: input?.execution_plan?.steps ?? [],

    },

    patch_spec: {

      format: input?.patch_spec?.format ?? "structured_patch",

      patches: input?.patch_spec?.patches ?? [],

    },

    validator_authority: {

      veto_authority: true,

      escalation_authority: true,

      audit_authority: true,

      intent_authority: false,

      authorship_authority: false,

      interpretation_authority: false,

      execution_authority: false,

      may_reject_invalid_envelope: true,

      may_block_delegation: true,

      may_escalate_failures: true,

      may_record_findings: true,

      may_create_intent: false,

      may_modify_intent: false,

      may_invent_intent_evidence: false,

      may_infer_missing_intent: false,

      may_resolve_intent_ambiguity: false,

      may_modify_envelope: false,

      may_execute_work: false,

      required_outputs: [

        "envelope_id",

        "validation_result",

        "findings",

        "severity",

        "category",

        "recommended_escalation_path",

        "timestamp",

        "checks_performed",

        "checks_passed",

        "checks_failed",

      ],

    },

    validation_contract: {

      pre_checks:

        input?.validation_contract?.pre_checks ?? [],

      post_checks:

        input?.validation_contract?.post_checks ?? [],

      success_criteria:

        input?.validation_contract?.success_criteria ?? [],

      failure_conditions:

        input?.validation_contract?.failure_conditions ?? [],

    },

    rollback_contract: {

      rollback_supported:

        input?.rollback_contract?.rollback_supported ?? true,

      rollback_method:

        input?.rollback_contract?.rollback_method ?? "git",

      rollback_trigger_conditions:

        input?.rollback_contract?.rollback_trigger_conditions ?? [],

      rollback_snapshot_id:

        input?.rollback_contract?.rollback_snapshot_id ?? null,

    },

    reconciliation: {

      required:

        input?.reconciliation?.required ?? true,

      reconciliation_type:

        input?.reconciliation?.reconciliation_type ??

        "diff_based",

      reconciliation_outputs:

        input?.reconciliation?.reconciliation_outputs ?? [

          "intended_vs_actual_diff",

          "validation_report",

          "execution_trace_summary",

        ],

    },

    sandbox: {

      dry_run_required:

        input?.sandbox?.dry_run_required ?? true,

      sandbox_mode:

        input?.sandbox?.sandbox_mode ?? "strict",

      allow_external_side_effects:

        input?.sandbox?.allow_external_side_effects ?? false,

    },

    governance_authority: {

      intent_authority: "user",

      interpreter: "matilda",

      executor: "cade",

      intent_creation_prohibited: true,

      inference_may_replace_missing_intent: false,

      ambiguity_policy: {

        deterministic_ambiguity: "matilda_may_resolve",

        interpretive_ambiguity:

          "matilda_may_resolve_with_user_visibility",

        intent_ambiguity: "escalate_to_user",

      },

    },

    delegation_authorization: {

      required: true,

      state:

        input?.delegation_authorization?.state ??

        "pending",

      delegated_by: "matilda",

      notes:

        input?.delegation_authorization?.notes ?? "",

    },

    cade_execution_constraints: {

      must_be_deterministic: true,

      must_be_bounded: true,

      must_not_expand_scope: true,

      must_not_override_mutation_scope: true,

      must_stop_on_validation_failure: true,

      must_not_create_intent: true,

      must_not_infer_missing_intent: true,

      must_pause_when_intent_evidence_insufficient: true,

    },

  };

}

