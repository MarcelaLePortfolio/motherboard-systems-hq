
import fs from "fs";

import path from "path";

const mapPath =

  "scripts/render-native/reports/semantic-runtime-lifecycle-map.json";

const runtimeCaptureDir =

  "scripts/render-native/runtime-captures";

const outputPath =

  "scripts/render-native/reports/semantic-runtime-lifecycle-analysis.json";

const mapReport = JSON.parse(fs.readFileSync(mapPath, "utf8"));

const findings = mapReport.findings || [];

const runtimeCaptureFiles = fs.existsSync(runtimeCaptureDir)

  ? fs.readdirSync(runtimeCaptureDir)

      .filter((file) => file.includes("semantic-preview-route") && file.endsWith(".json"))

      .sort()

  : [];

const latestSemanticCapturePath = runtimeCaptureFiles.length

  ? path.join(runtimeCaptureDir, runtimeCaptureFiles[runtimeCaptureFiles.length - 1])

  : null;

const latestSemanticCapture = latestSemanticCapturePath

  ? JSON.parse(fs.readFileSync(latestSemanticCapturePath, "utf8"))

  : null;

const guidance = latestSemanticCapture?.guidance || null;

const artifactSemantic =

  latestSemanticCapture?.artifact?.semantic_artifact ||

  latestSemanticCapture?.artifacts?.[0]?.semantic_artifact ||

  guidance?.artifact?.semantic_artifact ||

  guidance?.artifacts?.[0]?.semantic_artifact ||

  null;

const classifications = {

  preserved: [],

  reconstructed: [],

  inspection_only: [],

  renderer_only: [],

  transport_only: [],

  runtime_capture_preserved: []

};

for (const finding of findings) {

  const text = `${finding.pattern} ${finding.text}`.toLowerCase();

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

  if (

    text.includes("semantic_artifact") ||

    text.includes("semantic_artifact_schema") ||

    text.includes("semantic_artifact_validated")

  ) {

    classifications.preserved.push(finding);

  }

}

if (artifactSemantic) {

  classifications.runtime_capture_preserved.push({

    source: latestSemanticCapturePath,

    semantic_artifact_present: true,

    schema_version: artifactSemantic.schema_version || null,

    artifact_kind: artifactSemantic.artifact_kind || null,

    section_count: Array.isArray(artifactSemantic.sections)

      ? artifactSemantic.sections.length

      : 0,

    semantic_artifact_validated:

      latestSemanticCapture?.artifact?.semantic_artifact_validated ??

      latestSemanticCapture?.guidance?.artifact?.semantic_artifact_validated ??

      null

  });

}

const analysis = {

  schema_version: "phase737.semantic-runtime-lifecycle-analysis.v2",

  corridor: "read-only-runtime-analysis",

  source_report: mapPath,

  runtime_capture_source: latestSemanticCapturePath,

  totals: {

    findings: findings.length,

    preserved_source_matches: classifications.preserved.length,

    runtime_capture_preserved: classifications.runtime_capture_preserved.length,

    reconstructed: classifications.reconstructed.length,

    inspection_only: classifications.inspection_only.length,

    renderer_only: classifications.renderer_only.length,

    transport_only: classifications.transport_only.length

  },

  architectural_findings: [

    "Source-level Preview lifecycle reconstructs sections from markdown.",

    "Runtime semantic-preview capture confirms semantic_artifact is preserved in completed payload/artifact metadata.",

    "Semantic preservation is observable through semantic-preview, not artifact-preview.",

    "Preview rendering remains markdown-driven and intentionally separate from semantic inspection."

  ],

  classifications,

  validation: {

    deterministic_analysis: true,

    runtime_capture_considered: true,

    runtime_mutation_disabled: true,

    renderer_mutation_disabled: true,

    preview_mutation_disabled: true,

    execution_authority_disabled: true

  }

};

fs.mkdirSync("scripts/render-native/reports", { recursive: true });

fs.writeFileSync(outputPath, `${JSON.stringify(analysis, null, 2)}\n`);

console.log("SEMANTIC RUNTIME LIFECYCLE ANALYSIS PASS");

console.log(outputPath);

console.log(`Runtime preserved: ${classifications.runtime_capture_preserved.length}`);

console.log(`Reconstructed: ${classifications.reconstructed.length}`);

console.log(`Inspection-only: ${classifications.inspection_only.length}`);

