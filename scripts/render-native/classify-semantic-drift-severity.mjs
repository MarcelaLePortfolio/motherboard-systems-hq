
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const driftReportPath =

  process.argv[2] ||

  "scripts/render-native/reports/semantic-drift-report.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/reports/semantic-drift-severity-report.json";

const report = JSON.parse(readFileSync(driftReportPath, "utf8"));

function classifySeverity(driftType) {

  switch (driftType) {

    case "ontology_drift":

      return "high";

    case "topology_drift":

      return "medium";

    case "lineage_drift":

      return "medium";

    case "semantic_role_drift":

      return "medium";

    case "semantic_content_drift":

      return "low";

    default:

      return "unknown";

  }

}

const interpreted = report.interpreted_changes.map((node) => {

  const severities = node.drift_types.map((driftType) => ({

    drift_type: driftType,

    severity: classifySeverity(driftType)

  }));

  const highestSeverity =

    severities.some((s) => s.severity === "high")

      ? "high"

      : severities.some((s) => s.severity === "medium")

      ? "medium"

      : severities.some((s) => s.severity === "low")

      ? "low"

      : "unknown";

  return {

    id: node.id,

    drift_types: node.drift_types,

    severities,

    highest_severity: highestSeverity

  };

});

const severitySummary = {

  high: interpreted.filter((n) => n.highest_severity === "high").length,

  medium: interpreted.filter((n) => n.highest_severity === "medium").length,

  low: interpreted.filter((n) => n.highest_severity === "low").length,

  unknown: interpreted.filter((n) => n.highest_severity === "unknown").length

};

const severityReport = {

  schema_version:

    "phase736.semantic-drift-severity-report.v1",

  corridor: "sandbox-only-read-only",

  compared_snapshots: report.compared_snapshots,

  interpreted_nodes: interpreted,

  severity_summary: severitySummary,

  validation: {

    deterministic_severity_classification: true,

    semantic_only: true,

    reconciliation_disabled: true,

    rollback_authority_disabled: true,

    execution_authority_disabled: true

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(

  outputPath,

  `${JSON.stringify(severityReport, null, 2)}\n`

);

console.log("SEMANTIC DRIFT SEVERITY PASS");

console.log(`Severity report written to: ${outputPath}`);

