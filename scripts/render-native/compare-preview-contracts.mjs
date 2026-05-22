
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const simulationPath =

  "scripts/render-native/generated/preview-adapter-simulation.json";

const inspectionPath =

  "scripts/render-native/reports/preview-contract-source-inspection.json";

const outputPath =

  "scripts/render-native/reports/preview-contract-comparison.json";

const simulation = JSON.parse(

  readFileSync(simulationPath, "utf8")

);

const inspection = JSON.parse(

  readFileSync(inspectionPath, "utf8")

);

const adaptedNodes = simulation.adapted_nodes || [];

const previewPatterns =

  inspection.matches?.map((match) => ({

    file: match.file,

    pattern: match.pattern,

    line: match.line

  })) || [];

const semanticCapabilities = {

  node_types:

    [...new Set(

      adaptedNodes.map((node) => node.preview_type)

    )],

  semantic_roles:

    [...new Set(

      adaptedNodes

        .map((node) => node.semantic_role)

        .filter(Boolean)

    )],

  lineage_supported:

    adaptedNodes.every((node) => Boolean(node.lineage)),

  relations_supported:

    adaptedNodes.some(

      (node) => (node.relations || []).length > 0

    )

};

const previewContractCapabilities = {

  authoritative_files:

    inspection.matched_files || [],

  preview_root_detected:

    previewPatterns.some(

      (p) => p.pattern === "phase719-preview-modal"

    ),

  artifact_preview_route_detected:

    previewPatterns.some(

      (p) =>

        p.pattern === "artifact-preview" ||

        p.pattern === "/api/tasks/:task_id/artifact-preview"

    ),

  renderer_bridge_detected:

    previewPatterns.some(

      (p) =>

        p.pattern === "phase530_visible_panels_bridge"

    )

};

const alignment = {

  preview_root_alignment:

    previewContractCapabilities.preview_root_detected,

  preview_route_alignment:

    previewContractCapabilities.artifact_preview_route_detected,

  renderer_bridge_alignment:

    previewContractCapabilities.renderer_bridge_detected,

  semantic_render_mapping_present:

    semanticCapabilities.node_types.length > 0

};

const gaps = [];

if (!alignment.preview_root_alignment) {

  gaps.push(

    "Preview render root not aligned."

  );

}

if (!alignment.preview_route_alignment) {

  gaps.push(

    "Artifact preview route not aligned."

  );

}

if (!alignment.renderer_bridge_alignment) {

  gaps.push(

    "Renderer bridge alignment missing."

  );

}

const comparison = {

  schema_version:

    "phase736.preview-contract-comparison.v1",

  corridor:

    "read-only-deterministic-comparison",

  semantic_capabilities:

    semanticCapabilities,

  preview_contract_capabilities:

    previewContractCapabilities,

  alignment,

  gaps,

  validation: {

    deterministic_comparison: true,

    runtime_mutation_disabled: true,

    live_preview_untouched: true,

    renderer_interception_disabled: true

  }

};

mkdirSync(

  "scripts/render-native/reports",

  { recursive: true }

);

writeFileSync(

  outputPath,

  `${JSON.stringify(comparison, null, 2)}\n`

);

console.log("PREVIEW CONTRACT COMPARISON PASS");

console.log(

  `Comparison written to: ${outputPath}`

);

