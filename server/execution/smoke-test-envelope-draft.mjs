
import { buildExecutionEnvelopeDraft } from "./build-execution-envelope-draft.mjs";

import { validateGovernedExecutionEnvelope } from "./governance-validator.mjs";

const draft = buildExecutionEnvelopeDraft({

  intent: {

    actor: "Matilda",

    target: "Cade",

    objective: "Prepare governed documentation plan",

    requested_outcome: "Dry-run reconciliation-ready envelope",

    raw_user_intent: "Update execution documentation safely",

    source: "user_chat",

    tags: ["governance", "envelope"],

  },

  mutation_scope: {

    scope_type: "file",

    allowed_paths: ["docs/contracts/"],

    forbidden_paths: ["secrets/", ".env"],

    scope_constraints: "Docs-only smoke envelope",

  },

  execution_plan: {

    summary: "Prepare governed documentation plan",

    steps: [

      {

        step_id: "step-1",

        action: "inspect",

        target: "docs/contracts/example.md",

        instructions: "Plan only",

        expected_output: "Dry-run plan",

      },

    ],

  },

  patch_spec: {

    format: "structured_patch",

    patches: [

      {

        file: "docs/contracts/example.md",

        operation: "modify",

        content: "planned only",

      },

    ],

  },

});

const validation = validateGovernedExecutionEnvelope(draft.envelope);

console.log(JSON.stringify({

  ok: true,

  compiler: draft.compiler,

  envelope_version: draft.envelope.envelope_version,

  origin: draft.envelope.identity.origin,

  target: draft.envelope.identity.target,

  validation_ok: validation.ok,

  mutation_allowed: draft.envelope.execution_mode.mutation_allowed,

  shell_execution_allowed: draft.envelope.execution_mode.shell_execution_allowed,

  autonomous_execution_allowed: draft.envelope.execution_mode.autonomous_execution_allowed,

}, null, 2));

