
import {

  runGovernedPlanningPipeline,

} from "./governed-planning-pipeline.mjs";

import {

  buildGovernedPlanningArtifactBundle,

} from "./build-governed-planning-artifact-bundle.mjs";

const pipelineResult =

  runGovernedPlanningPipeline({

    intent: {

      actor: "Matilda",

      target: "Cade",

      objective:

        "Prepare governed bundled planning artifact",

      requested_outcome:

        "Canonical response, reconciliation, and audit bundle",

      raw_user_intent:

        "Bundle governed planning artifacts",

      source:

        "bundle_smoke_test",

      tags: [

        "governance",

        "bundle",

      ],

    },

    mutation_scope: {

      scope_type: "file",

      allowed_paths: ["docs/contracts/"],

      forbidden_paths: ["secrets/", ".env"],

      scope_constraints:

        "Docs-only bundle smoke",

    },

    execution_plan: {

      summary:

        "Prepare governed bundled planning artifact",

      steps: [

        {

          step_id: "step-1",

          action: "inspect",

          target:

            "docs/contracts/bundle-example.md",

          instructions:

            "Plan only",

          expected_output:

            "Bundled planning artifact",

        },

      ],

    },

    patch_spec: {

      format: "structured_patch",

      patches: [

        {

          file:

            "docs/contracts/bundle-example.md",

          operation:

            "modify",

          content:

            "planned only",

        },

      ],

    },

  });

const bundle =

  buildGovernedPlanningArtifactBundle({

    pipelineResult,

  });

console.log(JSON.stringify({

  ok: bundle.ok,

  bundle_schema:

    bundle.bundle_schema,

  phase:

    bundle.phase,

  envelope_version:

    bundle.envelope_version,

  response_schema:

    bundle.response.response_schema,

  reconciliation_schema:

    bundle.reconciliation.reconciliation_schema,

  ledger_schema:

    bundle.audit_ledger.ledger_schema,

  mutation_performed:

    bundle.execution_authority.mutation_performed,

  shell_execution_performed:

    bundle.execution_authority.shell_execution_performed,

  autonomous_execution_performed:

    bundle.execution_authority.autonomous_execution_performed,

}, null, 2));

