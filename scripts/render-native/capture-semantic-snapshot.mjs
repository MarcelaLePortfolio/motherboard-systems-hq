
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const timestamp = new Date()

  .toISOString()

  .replaceAll(":", "-")

  .replaceAll(".", "-");

const payloadPath =

  process.argv[2] ||

  "scripts/render-native/generated/compiled-semantic-payload.json";

const snapshotDir =

  "scripts/render-native/snapshots";

const payload = JSON.parse(readFileSync(payloadPath, "utf8"));

const snapshot = {

  schema_version: "phase736.semantic-snapshot.v1",

  snapshot_id: `semantic-snapshot-${timestamp}`,

  created_at: new Date().toISOString(),

  corridor: "sandbox-only",

  payload_schema_version: payload.schema_version,

  artifact_type: payload.artifact_type,

  validation: payload.validation,

  lineage: payload.lineage || null,

  semantic_summary: {

    node_count: payload.nodes?.length || 0,

    relation_count: payload.nodes?.reduce(

      (count, node) => count + ((node.relations || []).length),

      0

    ),

    lineage_enabled: payload.validation?.semantic_lineage === true,

    graph_enabled: payload.validation?.graph_structure === true

  },

  payload

};

mkdirSync(snapshotDir, { recursive: true });

const outputPath =

  `${snapshotDir}/${snapshot.snapshot_id}.json`;

writeFileSync(

  outputPath,

  `${JSON.stringify(snapshot, null, 2)}\n`

);

console.log("SEMANTIC SNAPSHOT CAPTURE PASS");

console.log(`Snapshot written to: ${outputPath}`);

