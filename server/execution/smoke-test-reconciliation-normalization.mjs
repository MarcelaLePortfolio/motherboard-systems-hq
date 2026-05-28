
import {

  normalizeReconciliationArtifact,

} from "./normalize-reconciliation-artifact.mjs";

const artifact =

  normalizeReconciliationArtifact({

    envelope_version:

      "matilda.cade.exec.v1",

    phase:

      "planning_completed",

    governance_ok: true,

    approval_gate_ok: true,

    cade_plan_ok: true,

    mutation_performed: false,

    shell_execution_performed: false,

    autonomous_execution_performed: false,

    reconciliation_entries: [

      {

        type: "planned_patch",

        file:

          "docs/contracts/example.md",

        operation:

          "modify",

        status:

          "planned_only",

      },

    ],

    trace: [

      {

        event:

          "reconciliation_normalized",

        ok: true,

      },

    ],

  });

console.log(JSON.stringify({

  ok: true,

  reconciliation_normalizer:

    "governed_reconciliation_normalizer",

  artifact,

}, null, 2));

