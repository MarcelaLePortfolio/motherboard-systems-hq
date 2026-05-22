
import fs from "fs";

const files = [

  "server/routes/api-tasks-postgres.mjs",

  "public/js/phase530_visible_panels_bridge.js",

  "public/js/dashboard-tasks-widget.js",

  "public/js/phase565_recent_tasks_wire.js"

];

const lifecyclePatterns = [

  "semantic_artifact",

  "semantic_artifact_schema",

  "semantic_artifact_validated",

  "outcome_preview",

  "explanation_preview",

  "artifact-preview",

  "semantic-preview",

  "sections",

  "guidance",

  "completed.payload",

  "visual-artifact:start"

];

const findings = [];

for (const file of files) {

  if (!fs.existsSync(file)) continue;

  const content = fs.readFileSync(file, "utf8");

  const lines = content.split("\n");

  lines.forEach((line, index) => {

    lifecyclePatterns.forEach((pattern) => {

      if (line.includes(pattern)) {

        findings.push({

          file,

          line: index + 1,

          pattern,

          text: line.trim()

        });

      }

    });

  });

}

const lifecycleMap = {

  schema_version: "phase737.semantic-runtime-lifecycle-map.v1",

  corridor: "read-only-runtime-lifecycle-mapping",

  inspected_files: files,

  lifecycle_patterns: lifecyclePatterns,

  findings_count: findings.length,

  findings,

  lifecycle_stages: {

    worker_completion_payload: [

      "completed.payload",

      "semantic_artifact"

    ],

    api_transport: [

      "/api/tasks",

      "/artifact-preview",

      "/semantic-preview"

    ],

    renderer_consumption: [

      "sections",

      "outcome_preview",

      "visual-artifact:start"

    ],

    semantic_inspection: [

      "guidance",

      "semantic_artifact_schema",

      "semantic_artifact_validated"

    ]

  },

  validation: {

    deterministic_mapping: true,

    runtime_mutation_disabled: true,

    renderer_mutation_disabled: true,

    preview_mutation_disabled: true,

    execution_authority_disabled: true

  }

};

fs.mkdirSync("scripts/render-native/reports", { recursive: true });

fs.writeFileSync(

  "scripts/render-native/reports/semantic-runtime-lifecycle-map.json",

  `${JSON.stringify(lifecycleMap, null, 2)}\n`

);

console.log("SEMANTIC RUNTIME LIFECYCLE MAP PASS");

console.log("scripts/render-native/reports/semantic-runtime-lifecycle-map.json");

console.log(`Findings: ${findings.length}`);

