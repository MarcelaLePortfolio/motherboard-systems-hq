
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const comparisonPath =

  process.argv[2] ||

  "scripts/render-native/reports/semantic-snapshot-comparison.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/reports/semantic-drift-report.json";

const comparison = JSON.parse(readFileSync(comparisonPath, "utf8"));

function classifyDifference(diff) {

  switch (diff.field) {

    case "relations":

      return "topology_drift";

    case "lineage":

      return "lineage_drift";

    case "meta":

      return "semantic_role_drift";

    case "content":

      return "semantic_content_drift";

    case "type":

      return "ontology_drift";

    default:

      return "unclassified_drift";

  }

}

const interpretedChanges = comparison.changed_nodes.map((node) => ({

  id: node.id,

  drift_types: [

    ...new Set(

      node.differences.map((difference) =>

        classifyDifference(difference)

      )

    )

  ],

  differences: node.differences

}));

const driftSummary = {

  topology_drift: 0,

  lineage_drift: 0,

  semantic_role_drift: 0,

  semantic_content_drift: 0,

  ontology_drift: 0,

  unclassified_drift: 0

};

for (const node of interpretedChanges) {

  for (const driftType of node.drift_types) {

    driftSummary[driftType]++;

  }

}

const report = {

  schema_version: "phase736.semantic-drift-report.v1",

  corridor: "sandbox-only-read-only",

  compared_snapshots: comparison.compared_snapshots,

  summary: {

    added_nodes: comparison.summary.added_node_count,

    removed_nodes: comparison.summary.removed_node_count,

    changed_nodes: comparison.summary.changed_node_count

  },

  interpreted_changes: interpretedChanges,

  drift_summary: driftSummary,

  validation: {

    deterministic_interpretation: true,

    semantic_only: true,

    reconciliation_not_enabled: true,

    execution_authority_disabled: true

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(

  outputPath,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log("SEMANTIC DRIFT INTERPRETATION PASS");

console.log(`Semantic drift report written to: ${outputPath}`);

