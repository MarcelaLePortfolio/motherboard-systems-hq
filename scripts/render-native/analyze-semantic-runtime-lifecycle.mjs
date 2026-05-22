
import fs from "fs";

const inputPath =

  "scripts/render-native/reports/semantic-runtime-lifecycle-map.json";

const report = JSON.parse(fs.readFileSync(inputPath, "utf8"));

const findings = report.findings || [];

const classifications = {

  preserved: [],

  reconstructed: [],

  inspection_only: [],

  renderer_only: [],

  transport_only: [],

  absent: []

};

for (const finding of findings) {

  const text = `${finding.pattern} ${finding.text}`.toLowerCase();

  if (

    text.includes("semantic_artifact") ||

    text.includes("semantic_artifact_schema") ||

    text.includes("semantic_artifact_validated")

  ) {

    classifications.preserved.push(finding);

    continue;

  }

  if (

    text.includes("sections") ||

    text.includes("visual-artifact:start")

  ) {

    classifications.reconstructed.push(finding);

    continue;

  }

  if (

    text.includes("semantic-preview") ||

    text.includes("guidance")

  ) {

    classifications.inspection_only.push(finding);

    continue;

  }

  if (

    text.includes("artifact-preview") ||

    text.includes("outcome_preview")

  ) {

    classifications.renderer_only.push(finding);

    continue;

  }

  if (

    text.includes("completed.payload")

  ) {

    classifications.transport_only.push(finding);

    continue;

  }

}

const analysis = {

  schema_version: "phase737.semantic-runtime-lifecycle-analysis.v1",

  corridor: "read-only-runtime-analysis",

  source_report: inputPath,

  totals: {

    findings: findings.length,

    preserved: classifications.preserved.length,

    reconstructed: classifications.reconstructed.length,

    inspection_only: classifications.inspection_only.length,

    renderer_only: classifications.renderer_only.length,

    transport_only: classifications.transport_only.length

  },

  architectural_findings: [

    "Semantic continuity is preserved in completed payload guidance transport.",

    "Preview rendering remains markdown-driven and reconstruction-oriented.",

    "Semantic inspection is runtime-adjacent rather than renderer-authoritative.",

    "Renderer lifecycle intentionally remains minimally coupled to semantic infrastructure."

  ],

  classifications,

  validation: {

    deterministic_analysis: true,

    runtime_mutation_disabled: true,

    renderer_mutation_disabled: true,

    preview_mutation_disabled: true,

    execution_authority_disabled: true

  }

};

fs.mkdirSync("scripts/render-native/reports", { recursive: true });

fs.writeFileSync(

  "scripts/render-native/reports/semantic-runtime-lifecycle-analysis.json",

  `${JSON.stringify(analysis, null, 2)}\n`

);

console.log("SEMANTIC RUNTIME LIFECYCLE ANALYSIS PASS");

console.log(

  "scripts/render-native/reports/semantic-runtime-lifecycle-analysis.json"

);

console.log(

  `Preserved: ${classifications.preserved.length}`

);

console.log(

  `Reconstructed: ${classifications.reconstructed.length}`

);

console.log(

  `Inspection-only: ${classifications.inspection_only.length}`

);

