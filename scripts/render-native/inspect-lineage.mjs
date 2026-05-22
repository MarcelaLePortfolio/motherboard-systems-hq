
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const inputPath =

  process.argv[2] ||

  "scripts/render-native/generated/compiled-semantic-payload.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/reports/lineage-report.json";

const payload = JSON.parse(readFileSync(inputPath, "utf8"));

const nodes = payload.nodes || [];

const nodeLineage = nodes.map((node) => ({

  id: node.id,

  type: node.type,

  semantic_role: node.meta?.semantic_role || null,

  lineage: node.lineage || null,

  has_lineage: Boolean(node.lineage),

  generated_from: node.lineage?.generated_from || null,

  emitted_by: node.lineage?.emitted_by || null,

  snapshot_source: node.lineage?.snapshot_source || null,

  lineage_scope: node.lineage?.lineage_scope || null

}));

const report = {

  schema_version: "phase736.semantic-lineage-report.v1",

  corridor: "sandbox-only-read-only",

  payload_schema_version: payload.schema_version,

  artifact_type: payload.artifact_type,

  payload_lineage: payload.lineage || null,

  node_count: nodes.length,

  node_lineage_count: nodeLineage.filter((node) => node.has_lineage).length,

  node_lineage: nodeLineage,

  validation: {

    semantic_lineage_present: payload.validation?.semantic_lineage === true,

    payload_lineage_present: Boolean(payload.lineage),

    all_nodes_have_lineage: nodeLineage.every((node) => node.has_lineage),

    lineage_scope_semantic_only: [

      payload.lineage?.lineage_scope,

      ...nodeLineage.map((node) => node.lineage_scope)

    ].every((scope) => scope === "semantic-only")

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(outputPath, `${JSON.stringify(report, null, 2)}\n`);

console.log("SEMANTIC LINEAGE INSPECTION PASS");

console.log(`Lineage report written to: ${outputPath}`);

if (!report.validation.all_nodes_have_lineage) {

  process.exit(1);

}

