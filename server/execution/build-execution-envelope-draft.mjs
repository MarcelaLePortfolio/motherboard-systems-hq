
import { EXECUTION_ENVELOPE_VERSION } from "../contracts/execution-envelope.v1.mjs";

import { normalizeExecutionIntent } from "./normalize-execution-intent.mjs";

function normalizeArray(value) {

  return Array.isArray(value) ? value : [];

}

export function buildExecutionEnvelopeDraft({

  intent = {},

  project_target = {},

  mutation_scope = {},

  execution_plan = {},

  patch_spec = {},

} = {}) {

  const intentResult = normalizeExecutionIntent(intent);

  const normalized = intentResult.normalized_intent;

  const envelope = {

    envelope_version: EXECUTION_ENVELOPE_VERSION,

    lifecycle_boundary: {

      artifact_role: "governed_planning_draft",

      execution_authorization: false,

      routing_authorization: false,

      mutation_authorization: false,

      shell_authorization: false,

      autonomous_authorization: false,

      notes:

        "This artifact preserves dry-run governed planning authority only and must not be treated as runtime execution authorization.",

    },

    identity: {

      envelope_id: `env-${Date.now()}`,

      intent_id: normalized.intent_id,

      timestamp: new Date().toISOString(),

      origin: "matilda",

      target: "cade",

    },

    intent: {

      raw_user_intent: intent.raw_user_intent ?? null,

      normalized_intent: normalized.objective,

      intent_type: "inspect",

      confidence_score: 1,

      requested_outcome: normalized.requested_outcome,

    },

    project_target: {

      project_name: project_target.project_name ?? "Motherboard Systems",

      repo_url: project_target.repo_url ?? null,

      repo_path: project_target.repo_path ?? process.cwd(),

      branch: project_target.branch ?? null,

      workspace_type: project_target.workspace_type ?? "motherboard_systems",

    },

    mutation_scope: {

      scope_type: mutation_scope.scope_type ?? "file",

      allowed_paths: normalizeArray(mutation_scope.allowed_paths),

      forbidden_paths: normalizeArray(mutation_scope.forbidden_paths),

      scope_constraints:

        mutation_scope.scope_constraints ??

        "Draft envelope generated from normalized intent",

    },

    execution_plan: {

      summary:

        execution_plan.summary ??

        normalized.objective,

      steps: normalizeArray(execution_plan.steps),

    },

    patch_spec: {

      format: patch_spec.format ?? "structured_patch",

      patches: normalizeArray(patch_spec.patches),

    },

    validation_contract: {

      pre_checks: ["canonical governance validation required"],

      post_checks: ["reconciliation-ready output required"],

      success_criteria: [

        "Envelope validates",

        "Planning remains dry-run only",

        "Planning draft cannot authorize runtime execution",

      ],

      failure_conditions: [

        "Invalid scope",

        "Forbidden path",

        "Mutation authority requested",

        "Runtime execution authorization inferred from planning draft",

      ],

    },

    rollback_contract: {

      rollback_supported: true,

      rollback_method: "git",

      rollback_trigger_conditions: [

        "governance validation failure",

        "forbidden path detected",

      ],

      rollback_snapshot_id: null,

    },

    reconciliation: {

      required: true,

      reconciliation_type: "diff_based",

      reconciliation_outputs: [

        "intended_vs_actual_diff",

        "validation_report",

        "execution_trace_summary",

      ],

    },

    sandbox: {

      dry_run_required: true,

      sandbox_mode: "strict",

      allow_external_side_effects: false,

    },

    execution_mode: {

      mutation_allowed: false,

      shell_execution_allowed: false,

      autonomous_execution_allowed: false,

    },

    delegation_authorization: {

      state: "delegated",

      notes:

        "Draft envelope authorizes governed planning only; it does not authorize routing, mutation, shell execution, autonomous execution, or runtime execution.",

    },

    cade_execution_constraints: {

      must_be_deterministic: true,

      must_be_bounded: true,

      must_not_expand_scope: true,

      must_not_override_mutation_scope: true,

      must_stop_on_validation_failure: true,

    },

  };

  return {

    ok: true,

    compiler: "matilda_execution_envelope_draft_builder",

    envelope,

    intent_trace: intentResult.trace,

    trace: [

      {

        event: "intent_normalized",

        ok: true,

      },

      {

        event: "execution_envelope_draft_constructed",

        ok: true,

      },

      {

        event: "planning_only_authority_preserved",

        ok: true,

      },

      {

        event: "runtime_execution_authority_explicitly_absent",

        ok: true,

      },

    ],

  };

}

