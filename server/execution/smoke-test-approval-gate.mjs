
import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

import { evaluateExecutionApproval } from "./execution-approval-gate.mjs";

import { buildApprovalArtifact } from "./build-approval-artifact.mjs";

import { EXECUTION_ENVELOPE_VERSION } from "../contracts/execution-envelope.v1.mjs";

const envelope = {

  envelope_version: EXECUTION_ENVELOPE_VERSION,

  identity: {

    envelope_id: "env-approval-gate-smoke-001",

    intent_id: "intent-approval-gate-smoke-001",

    timestamp: new Date().toISOString(),

    origin: "matilda",

    target: "cade",

  },

  project_target: {

    project_name: "Motherboard Systems",

    repo_path: process.cwd(),

    workspace_type: "motherboard_systems",

  },

  delegation_authorization: {

    state: "delegated",

    notes: "Approval gate smoke validates planning-only authority",

  },

  sandbox: {

    dry_run_required: true,

    allow_external_side_effects: false,

  },

  execution_mode: {

    mutation_allowed: false,

    shell_execution_allowed: false,

    autonomous_execution_allowed: false,

  },

  rollback_contract: {

    rollback_supported: true,

    rollback_method: "git",

    rollback_trigger_conditions: ["governance validation failure"],

  },

  reconciliation: {

    required: true,

    reconciliation_type: "diff_based",

  },

  validation_contract: {

    success_criteria: ["Approval gate returns planning-only authority"],

  },

  mutation_scope: {

    scope_type: "file",

    allowed_paths: ["docs/contracts/"],

    forbidden_paths: ["secrets/", ".env"],

    scope_constraints: "Docs-only approval gate smoke",

  },

  execution_plan: {

    summary: "Governed approval gate planning validation",

    steps: [

      {

        step_id: "step-1",

        action: "inspect",

        target: "docs/contracts/test.md",

        instructions: "Validate approval gate without mutation",

        expected_output: "Planning-only approval artifact",

      },

    ],

  },

  patch_spec: {

    format: "structured_patch",

    patches: [

      {

        file: "docs/contracts/test.md",

        operation: "modify",

        content: "planned only",

      },

    ],

  },

};

const governance = validateGovernedExecutionEnvelope(envelope);

const approval = buildApprovalArtifact({

  requested_by: "Matilda",

});

const result = evaluateExecutionApproval({

  envelope,

  governance,

  approval,

});

console.log(JSON.stringify(result, null, 2));

