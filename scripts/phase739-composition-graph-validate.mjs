
import fs from "fs";

const graphPath = "SANDBOX_COMPOSITION_GRAPH_SAMPLE_PHASE739.json";

const payloadPath = "SANDBOX_PREVIEW_SAMPLE_PAYLOAD_PHASE739.json";

const failures = [];

function readJson(path) {

  if (!fs.existsSync(path)) {

    failures.push(`Missing file: ${path}`);

    return null;

  }

  try {

    return JSON.parse(fs.readFileSync(path, "utf8"));

  } catch (error) {

    failures.push(`Invalid JSON in ${path}: ${error.message}`);

    return null;

  }

}

const graph = readJson(graphPath);

const payload = readJson(payloadPath);

if (graph) {

  if (graph.graph_version !== "sandbox-composition-graph.v1") {

    failures.push("Invalid graph_version");

  }

  if (graph.sandbox_only !== true) {

    failures.push("graph.sandbox_only must be true");

  }

  if (!Array.isArray(graph.root_nodes)) {

    failures.push("root_nodes must be an array");

  }

  if (!Array.isArray(graph.relationships)) {

    failures.push("relationships must be an array");

  }

  if (!graph.layout_metadata || graph.layout_metadata.sandbox_only !== true) {

    failures.push("layout_metadata.sandbox_only must be true");

  }

}

if (graph && payload) {

  const payloadComponentIds = new Set((payload.components || []).map((component) => component.component_id));

  const graphNodeIds = new Set();

  for (const node of graph.root_nodes || []) {

    if (!node.node_id) failures.push("Node missing node_id");

    if (!node.component_id) failures.push("Node missing component_id");

    if (!node.layout_role) failures.push("Node missing layout_role");

    if (node.node_id) graphNodeIds.add(node.node_id);

    if (node.component_id && !payloadComponentIds.has(node.component_id)) {

      failures.push(`Node references missing payload component: ${node.component_id}`);

    }

  }

  for (const relationship of graph.relationships || []) {

    if (!relationship.relationship_id) failures.push("Relationship missing relationship_id");

    if (!relationship.source_node_id) failures.push("Relationship missing source_node_id");

    if (!relationship.target_node_id) failures.push("Relationship missing target_node_id");

    if (!relationship.relationship_type) failures.push("Relationship missing relationship_type");

    if (relationship.source_node_id && !graphNodeIds.has(relationship.source_node_id)) {

      failures.push(`Relationship source missing node: ${relationship.source_node_id}`);

    }

    if (relationship.target_node_id && !graphNodeIds.has(relationship.target_node_id)) {

      failures.push(`Relationship target missing node: ${relationship.target_node_id}`);

    }

  }

}

if (failures.length > 0) {

  console.log("❌ Phase 739 composition graph validation FAILED");

  for (const failure of failures) console.log(`- ${failure}`);

  process.exit(1);

}

console.log("✅ Phase 739 composition graph validation PASSED");

console.log(`Validated: ${graphPath}`);

console.log(`Against payload: ${payloadPath}`);

