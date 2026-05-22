
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const inputPath =

  "scripts/render-native/reports/semantic-artifact-propagation-trace.json";

const outputPath =

  "scripts/render-native/reports/semantic-artifact-propagation-trace-narrow.json";

const trace = JSON.parse(readFileSync(inputPath, "utf8"));

const priorityFiles = [

  "server/routes/api-tasks-postgres.mjs",

  "public/js/phase530_visible_panels_bridge.js",

  "public/js/dashboard-tasks-widget.js",

  "public/js/phase565_recent_tasks_wire.js"

];

const lifecyclePatterns = [

  "semantic_artifact",

  "artifact_kind",

  "schema_version",

  "sections",

  "outcome_preview",

  "artifact-preview"

];

const matches = (trace.matches || []).filter((match) =>

  priorityFiles.includes(match.file) &&

  lifecyclePatterns.includes(match.pattern)

);

const groupedFiles = [...new Set(matches.map((match) => match.file))].sort();

const report = {

  schema_version: "phase736.semantic-artifact-propagation-trace-narrow.v1",

  corridor: "read-only-lifecycle-tracing",

  purpose: "Narrow semantic artifact propagation trace to authoritative route, renderer, and dashboard lifecycle files.",

  priority_files: priorityFiles,

  lifecycle_patterns: lifecyclePatterns,

  matched_file_count: groupedFiles.length,

  matched_files: groupedFiles,

  matches,

  constraints: {

    runtime_mutated: false,

    live_preview_mutated: false,

    renderer_intercepted: false,

    browser_injected: false

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(outputPath, `${JSON.stringify(report, null, 2)}\n`);

console.log("NARROW SEMANTIC PROPAGATION TRACE PASS");

console.log(outputPath);

console.log(`Matched files: ${groupedFiles.length}`);

