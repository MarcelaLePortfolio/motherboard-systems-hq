
import fs from "fs";

const renderPath = "SANDBOX_MULTI_COMPONENT_RENDER_SAMPLE_PHASE740.json";

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

if (render) {

  if (render.artifact_version !== "sandbox-mock-render.v1") {

    failures.push("Invalid artifact_version");

  }

  if (render.sandbox_only !== true) {

    failures.push("sandbox_only must be true");

  }

  if (!Array.isArray(render.render_nodes)) {

    failures.push("render_nodes must be an array");

  }

  if (!Array.isArray(render.render_relationships)) {

    failures.push("render_relationships must be an array");

  }

  if (!render.render_metadata || typeof render.render_metadata !== "object") {

    failures.push("render_metadata missing");

  } else {

    if (render.render_metadata.sandbox_only !== true) {

      failures.push("render_metadata.sandbox_only must be true");

    }

    if (render.render_metadata.runtime_authority !== false) {

      failures.push("runtime_authority must be false");

    }

    if (render.render_metadata.preview_authority !== false) {

      failures.push("preview_authority must be false");

    }

  }

  const nodeIds = new Set();

  for (const node of render.render_nodes || []) {

    if (!node.render_node_id) {

      failures.push("render_node_id missing");

    }

    if (!node.component_id) {

      failures.push("component_id missing");

    }

    if (!node.render_type) {

      failures.push("render_type missing");

    }

    if (!node.layout_role) {

      failures.push("layout_role missing");

    }

    if (node.render_node_id) {

      nodeIds.add(node.render_node_id);

    }

  }

  for (const relationship of render.render_relationships || []) {

    if (!relationship.relationship_id) {

      failures.push("relationship_id missing");

    }

    if (!relationship.source_render_node_id) {

      failures.push("source_render_node_id missing");

    }

    if (!relationship.target_render_node_id) {

      failures.push("target_render_node_id missing");

    }

    if (!relationship.relationship_type) {

      failures.push("relationship_type missing");

    }

    if (

      relationship.source_render_node_id &&

      !nodeIds.has(relationship.source_render_node_id)

    ) {

      failures.push(

        `Missing source render node: ${relationship.source_render_node_id}`

      );

    }

    if (

      relationship.target_render_node_id &&

      !nodeIds.has(relationship.target_render_node_id)

    ) {

      failures.push(

        `Missing target render node: ${relationship.target_render_node_id}`

      );

    }

  }

}

if (failures.length > 0) {

  console.log("❌ Phase 740 multi-component render validation FAILED");

  for (const failure of failures) {

    console.log(`- ${failure}`);

  }

  process.exit(1);

}

console.log("✅ Phase 740 multi-component render validation PASSED");

console.log(`Validated: ${renderPath}`);

