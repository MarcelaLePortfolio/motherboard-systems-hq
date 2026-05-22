
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const snapshotAPath = process.argv[2];

const snapshotBPath = process.argv[3];

const outputPath =

  process.argv[4] ||

  "scripts/render-native/reports/semantic-snapshot-comparison.json";

if (!snapshotAPath || !snapshotBPath) {

  console.error("Usage:");

  console.error(

    "node scripts/render-native/compare-semantic-snapshots.mjs <snapshotA> <snapshotB>"

  );

  process.exit(1);

}

const snapshotA = JSON.parse(readFileSync(snapshotAPath, "utf8"));

const snapshotB = JSON.parse(readFileSync(snapshotBPath, "utf8"));

const payloadA = snapshotA.payload;

const payloadB = snapshotB.payload;

const nodesA = payloadA.nodes || [];

const nodesB = payloadB.nodes || [];

const nodeMapA = new Map(nodesA.map((node) => [node.id, node]));

const nodeMapB = new Map(nodesB.map((node) => [node.id, node]));

const addedNodes = [];

const removedNodes = [];

const changedNodes = [];

for (const [id, nodeB] of nodeMapB.entries()) {

  if (!nodeMapA.has(id)) {

    addedNodes.push({

      id,

      type: nodeB.type

    });

    continue;

  }

  const nodeA = nodeMapA.get(id);

  const differences = [];

  if (nodeA.type !== nodeB.type) {

    differences.push({

      field: "type",

      before: nodeA.type,

      after: nodeB.type

    });

  }

  if (

    JSON.stringify(nodeA.meta || {}) !==

    JSON.stringify(nodeB.meta || {})

  ) {

    differences.push({

      field: "meta",

      before: nodeA.meta || {},

      after: nodeB.meta || {}

    });

  }

  if (

    JSON.stringify(nodeA.relations || []) !==

    JSON.stringify(nodeB.relations || [])

  ) {

    differences.push({

      field: "relations",

      before: nodeA.relations || [],

      after: nodeB.relations || []

    });

  }

  if (

    JSON.stringify(nodeA.lineage || {}) !==

    JSON.stringify(nodeB.lineage || {})

  ) {

    differences.push({

      field: "lineage",

      before: nodeA.lineage || {},

      after: nodeB.lineage || {}

    });

  }

  if (

    JSON.stringify(nodeA.content || {}) !==

    JSON.stringify(nodeB.content || {})

  ) {

    differences.push({

      field: "content",

      before: nodeA.content || {},

      after: nodeB.content || {}

    });

  }

  if (differences.length > 0) {

    changedNodes.push({

      id,

      differences

    });

  }

}

for (const [id, nodeA] of nodeMapA.entries()) {

  if (!nodeMapB.has(id)) {

    removedNodes.push({

      id,

      type: nodeA.type

    });

  }

}

const comparison = {

  schema_version:

    "phase736.semantic-snapshot-comparison.v1",

  corridor: "sandbox-only-read-only",

  compared_snapshots: {

    before: snapshotA.snapshot_id,

    after: snapshotB.snapshot_id

  },

  compared_payload_versions: {

    before: payloadA.schema_version,

    after: payloadB.schema_version

  },

  summary: {

    nodes_before: nodesA.length,

    nodes_after: nodesB.length,

    added_node_count: addedNodes.length,

    removed_node_count: removedNodes.length,

    changed_node_count: changedNodes.length

  },

  added_nodes: addedNodes,

  removed_nodes: removedNodes,

  changed_nodes: changedNodes,

  validation: {

    deterministic_comparison: true,

    semantic_lineage_compared: true,

    semantic_relations_compared: true,

    graph_structure_compared: true

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(

  outputPath,

  `${JSON.stringify(comparison, null, 2)}\n`

);

console.log("SEMANTIC SNAPSHOT COMPARISON PASS");

console.log(`Comparison report written to: ${outputPath}`);

