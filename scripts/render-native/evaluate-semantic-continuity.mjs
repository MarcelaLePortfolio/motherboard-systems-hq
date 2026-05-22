
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const severityReportPath =

  process.argv[2] ||

  "scripts/render-native/reports/semantic-drift-severity-report.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/reports/semantic-continuity-report.json";

const report = JSON.parse(readFileSync(severityReportPath, "utf8"));

const interpretedNodes = report.interpreted_nodes || [];

function calculateContinuityScore(node) {

  if (node.highest_severity === "high") {

    return 25;

  }

  if (node.highest_severity === "medium") {

    return 65;

  }

  if (node.highest_severity === "low") {

    return 90;

  }

  return 100;

}

const evaluatedNodes = interpretedNodes.map((node) => {

  const continuityScore = calculateContinuityScore(node);

  let continuityState = "stable";

  if (continuityScore <= 30) {

    continuityState = "critical";

  } else if (continuityScore <= 70) {

    continuityState = "degraded";

  }

  return {

    id: node.id,

    drift_types: node.drift_types,

    highest_severity: node.highest_severity,

    continuity_score: continuityScore,

    continuity_state: continuityState

  };

});

const overallScore =

  evaluatedNodes.length > 0

    ? Math.round(

        evaluatedNodes.reduce(

          (sum, node) => sum + node.continuity_score,

          0

        ) / evaluatedNodes.length

      )

    : 100;

let overallState = "stable";

if (overallScore <= 30) {

  overallState = "critical";

} else if (overallScore <= 70) {

  overallState = "degraded";

}

const reportOutput = {

  schema_version:

    "phase736.semantic-continuity-report.v1",

  corridor: "sandbox-only-read-only",

  compared_snapshots: report.compared_snapshots,

  evaluated_nodes: evaluatedNodes,

  overall_continuity: {

    score: overallScore,

    state: overallState

  },

  validation: {

    deterministic_continuity_evaluation: true,

    semantic_only: true,

    reconciliation_disabled: true,

    rollback_authority_disabled: true,

    execution_authority_disabled: true

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(

  outputPath,

  `${JSON.stringify(reportOutput, null, 2)}\n`

);

console.log("SEMANTIC CONTINUITY EVALUATION PASS");

console.log(`Continuity report written to: ${outputPath}`);

