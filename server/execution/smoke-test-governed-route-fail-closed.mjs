
import { runGovernedPlanningPipeline }

  from "./governed-planning-pipeline.mjs";

try {

  await runGovernedPlanningPipeline({

    intent: {

      actor: "Matilda",

      target: "Cade",

      // intentionally omitted objective

      requested_outcome:

        "Attempt invalid governed request",

      source: "fail_closed_smoke",

      tags: [

        "governance",

        "fail_closed",

      ],

    },

    mutation_scope: {

      scope_type: "file",

      allowed_paths: ["docs/contracts/"],

      forbidden_paths: ["secrets/"],

    },

    execution_plan: {

      summary: "Invalid request",

      steps: [],

    },

    patch_spec: {

      format: "structured_patch",

      patches: [],

    },

  });

  console.error("UNEXPECTED_PASS");

  process.exit(1);

} catch (err) {

  console.log(JSON.stringify({

    ok: true,

    fail_closed_verified: true,

    code: err.code,

    message: (err as any).message,

    mutation_performed: false,

    shell_execution_performed: false,

    autonomous_execution_performed: false,

  }, null, 2));

}

