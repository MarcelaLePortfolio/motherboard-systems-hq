
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const continuityReportPath =

  process.argv[2] ||

  "scripts/render-native/reports/semantic-continuity-report.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/reports/semantic-advisories-report.json";

const report = JSON.parse(

  readFileSync(continuityReportPath, "utf8")

);

function advisoryForNode(node) {

  switch (node.continuity_state) {

    case "critical":

      return {

        advisory_level: "high",

        advisory_type: "continuity_risk",

        message:

          "Semantic continuity degraded critically. Structural inspection recommended."

      };

    case "degraded":

      return {

        advisory_level: "medium",

        advisory_type: "continuity_review",

        message:

          "Semantic continuity degraded. Review semantic drift before further evolution."

      };

    default:

      return {

        advisory_level: "low",

        advisory_type: "continuity_stable",

        message:

          "Semantic continuity remains structurally stable."

      };

  }

}

const nodeAdvisories = report.evaluated_nodes.map((node) => ({

  id: node.id,

  continuity_state: node.continuity_state,

  continuity_score: node.continuity_score,

  advisory: advisoryForNode(node)

}));

const overallAdvisory =

  report.overall_continuity.state === "critical"

    ? {

        level: "high",

        recommendation:

          "Pause semantic evolution pending structural inspection."

      }

    : report.overall_continuity.state === "degraded"

    ? {

        level: "medium",

        recommendation:

          "Continue cautiously with semantic inspection checkpoints."

      }

    : {

        level: "low",

        recommendation:

          "Semantic continuity remains stable for sandbox evolution."

      };

const advisoryReport = {

  schema_version:

    "phase736.semantic-advisories-report.v1",

  corridor: "sandbox-only-read-only",

  compared_snapshots: report.compared_snapshots,

  overall_continuity: report.overall_continuity,

  overall_advisory: overallAdvisory,

  node_advisories: nodeAdvisories,

  validation: {

    deterministic_advisories: true,

    semantic_only: true,

    reconciliation_disabled: true,

    rollback_authority_disabled: true,

    execution_authority_disabled: true

  }

};

mkdirSync("scripts/render-native/reports", {

  recursive: true

});

writeFileSync(

  outputPath,

  `${JSON.stringify(advisoryReport, null, 2)}\n`

);

console.log("SEMANTIC ADVISORY GENERATION PASS");

console.log(`Advisory report written to: ${outputPath}`);

