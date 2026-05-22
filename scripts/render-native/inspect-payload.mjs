
import fs from "fs";

const payloadPath = process.argv[2];

if (!payloadPath) {

  console.error("Missing payload path.");

  process.exit(1);

}

const raw = fs.readFileSync(payloadPath, "utf8");

const payload = JSON.parse(raw);

const report = {

  schema_version: payload.schema_version,

  artifact_type: payload.artifact_type,

  node_count: payload.nodes.length,

  node_types: {},

  style_token_count: Object.keys(payload.style_tokens || {}).length,

  layout_token_count: Object.keys(payload.layout_tokens || {}).length,

  referenced_style_tokens: {},

  referenced_layout_tokens: {},

  deterministic: payload.validation?.deterministic === true,

  sandbox_only: payload.validation?.sandbox_only === true

};

for (const node of payload.nodes) {

  report.node_types[node.type] =

    (report.node_types[node.type] || 0) + 1;

  if (node.style_token) {

    report.referenced_style_tokens[node.style_token] =

      (report.referenced_style_tokens[node.style_token] || 0) + 1;

  }

  if (node.layout_token) {

    report.referenced_layout_tokens[node.layout_token] =

      (report.referenced_layout_tokens[node.layout_token] || 0) + 1;

  }

}

const outputPath =

  "scripts/render-native/reports/payload-inspection-report.json";

fs.writeFileSync(

  outputPath,

  JSON.stringify(report, null, 2)

);

console.log("INSPECTION PASS");

console.log(`Inspection report written to: ${outputPath}`);

