
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const inputPath =

  process.argv[2] ||

  "scripts/render-native/generated/compiled-semantic-payload.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/reports/graph-relations-report.json";

const payload = JSON.parse(readFileSync(inputPath, "utf8"));

const nodeIds = new Set(payload.nodes.map((node) => node.id));

const relations = payload.nodes.flatMap((node) =>

  (node.relations || []).map((relation) => ({

    source: node.id,

    type: relation.type,

    target: relation.target,

    target_exists: nodeIds.has(relation.target)

  }))

);

const report = {

  schema_version: "phase736.graph-relations-report.v1",

  corridor: "sandbox-only-read-only",

  payload_schema_version: payload.schema_version,

  artifact_type: payload.artifact_type,

  node_count: payload.nodes.length,

  relation_count: relations.length,

  nodes: payload.nodes.map((node) => ({

    id: node.id,

    type: node.type,

    semantic_role: node.meta?.semantic_role || null,

    relation_count: (node.relations || []).length

  })),

  relations,

  invalid_relations: relations.filter((relation) => !relation.target_exists),

  validation: {

    graph_structure_present: payload.validation?.graph_structure === true,

    semantic_relations_present: payload.validation?.semantic_relations === true,

    all_relation_targets_exist: relations.every((relation) => relation.target_exists)

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(outputPath, `${JSON.stringify(report, null, 2)}\n`);

console.log("GRAPH RELATIONS INSPECTION PASS");

console.log(`Graph relations report written to: ${outputPath}`);

if (!report.validation.all_relation_targets_exist) {

  process.exit(1);

}

