
import fs from "fs";

const renderPath = "SANDBOX_MOCK_RENDER_SAMPLE_PHASE740.json";

const payloadPath = "SANDBOX_PREVIEW_SAMPLE_PAYLOAD_PHASE739.json";

const graphPath = "SANDBOX_COMPOSITION_GRAPH_SAMPLE_PHASE739.json";

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

const render = readJson(renderPath);

const payload = readJson(payloadPath);

const graph = readJson(graphPath);

if (render) {

  if (render.artifact_version !== "sandbox-mock-render.v1") failures.push("Invalid artifact_version");

  if (render.payload_reference !== payloadPath) failures.push("Invalid payload_reference");

  if (render.composition_graph_reference !== graphPath) failures.push("Invalid composition_graph_reference");

  if (render.sandbox_only !== true) failures.push("render.sandbox_only must be true");

  if (!Array.isArray(render.render_nodes)) failures.push("render_nodes must be an array");

  if (!render.render_metadata || typeof render.render_metadata !== "object") {

    failures.push("render_metadata must be an object");

  } else {

    if (render.render_metadata.sandbox_only !== true) failures.push("render_metadata.sandbox_only must be true");

    if (render.render_metadata.runtime_authority !== false) failures.push("render_metadata.runtime_authority must be false");

    if (render.render_metadata.preview_authority !== false) failures.push("render_metadata.preview_authority must be false");

  }

}

if (render && payload && graph) {

  const payloadComponentIds = new Set((payload.components || []).map((component) => component.component_id));

  const graphComponentIds = new Set((graph.root_nodes || []).map((node) => node.component_id));

  for (const node of render.render_nodes || []) {

    if (!node.render_node_id) failures.push("Render node missing render_node_id");

    if (!node.component_id) failures.push("Render node missing component_id");

    if (!node.render_type) failures.push("Render node missing render_type");

    if (!node.layout_role) failures.push("Render node missing layout_role");

    if (node.component_id && !payloadComponentIds.has(node.component_id)) {

      failures.push(`Render node references missing payload component: ${node.component_id}`);

    }

    if (node.component_id && !graphComponentIds.has(node.component_id)) {

      failures.push(`Render node references missing graph component: ${node.component_id}`);

    }

  }

}

if (failures.length > 0) {

  console.log("❌ Phase 740 mock render validation FAILED");

  for (const failure of failures) console.log(`- ${failure}`);

  process.exit(1);

}

console.log("✅ Phase 740 mock render validation PASSED");

console.log(`Validated: ${renderPath}`);

console.log(`Against payload: ${payloadPath}`);

console.log(`Against graph: ${graphPath}`);

