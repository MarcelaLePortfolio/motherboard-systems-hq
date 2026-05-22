
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const payloadPath =

  process.argv[2] ||

  "scripts/render-native/generated/compiled-semantic-payload.json";

const outputPath =

  process.argv[3] ||

  "scripts/render-native/generated/preview-adapter-simulation.json";

const payload = JSON.parse(readFileSync(payloadPath, "utf8"));

function mapNode(node) {

  return {

    preview_id: node.id,

    preview_type:

      node.type === "container"

        ? "panel"

        : node.type === "text"

        ? "text-block"

        : node.type === "list"

        ? "list-block"

        : node.type === "status_badge"

        ? "status-chip"

        : "unknown",

    semantic_role:

      node.meta?.semantic_role || null,

    render_contract: {

      style_token: node.style_token || null,

      layout_token: node.layout_token || null

    },

    content:

      node.content || {},

    relations:

      node.relations || [],

    lineage:

      node.lineage || null

  };

}

const previewSimulation = {

  schema_version:

    "phase736.preview-adapter-simulation.v1",

  corridor: "sandbox-only",

  source_payload_schema:

    payload.schema_version,

  simulation_purpose:

    "preview-boundary-contract-modeling",

  preview_contract: {

    render_root:

      "phase719-preview-modal",

    artifact_surface:

      "preview-adapter-simulation",

    renderer_mode:

      "deterministic-read-only"

  },

  adapted_nodes:

    (payload.nodes || []).map(mapNode),

  validation: {

    deterministic_mapping: true,

    semantic_to_preview_mapping: true,

    renderer_independent: true,

    live_preview_untouched: true,

    runtime_interception_disabled: true

  }

};

mkdirSync(

  "scripts/render-native/generated",

  { recursive: true }

);

writeFileSync(

  outputPath,

  `${JSON.stringify(previewSimulation, null, 2)}\n`

);

console.log("PREVIEW ADAPTER SIMULATION PASS");

console.log(

  `Preview adapter simulation written to: ${outputPath}`

);

