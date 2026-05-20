
import fs from "fs";

import path from "path";

const repoRoot = process.cwd();

const candidatePatterns = [

  "phase530_visible_panels_bridge.js",

  "phase719-preview-modal",

  "artifact-preview",

  "preview-body",

  "semantic-artifact",

  "visual-artifact",

  "data-phase733-single-artifact-render",

  "phase723SanitizeVisualArtifactHtml",

  "phase735DecodeVisualArtifactHtmlTransport",

];

const ignoredDirs = new Set([

  ".git",

  "node_modules",

  ".next",

  "ARTIFACT_SNAPSHOTS",

  "FULL_PREVIEW_RUNS",

  "DISASTER_RECOVERY",

  "RENDER_NATIVE_SCENES",

  "RENDER_NATIVE_LAYOUTS",

  "RENDER_NATIVE_ORCHESTRATION",

  "RENDER_NATIVE_DASHBOARD_CONTRACTS",

  "RENDER_NATIVE_RUNTIME",

]);

function walk(dir, files = []) {

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {

    if (ignoredDirs.has(entry.name)) continue;

    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {

      walk(fullPath, files);

      continue;

    }

    if (

      entry.name.endsWith(".js") ||

      entry.name.endsWith(".mjs") ||

      entry.name.endsWith(".ts") ||

      entry.name.endsWith(".tsx") ||

      entry.name.endsWith(".html") ||

      entry.name.endsWith(".css")

    ) {

      files.push(fullPath);

    }

  }

  return files;

}

function inspectFile(filePath) {

  const text = fs.readFileSync(filePath, "utf8");

  const matches = [];

  for (const pattern of candidatePatterns) {

    if (text.includes(pattern)) {

      matches.push(pattern);

    }

  }

  if (!matches.length) return null;

  return {

    path: path.relative(repoRoot, filePath),

    matches,

  };

}

const inspectedFiles = walk(repoRoot);

const results = inspectedFiles

  .map(inspectFile)

  .filter(Boolean)

  .sort((a, b) => a.path.localeCompare(b.path));

const report = {

  schemaVersion: "phase736.renderer-consumption-target-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  purpose:

    "Identify renderer files and preview runtime targets before any render-native dashboard implementation mutation.",

  candidatePatterns,

  resultCount: results.length,

  results,

  nextRecommendedStep:

    "Inspect highest-confidence renderer target manually before modifying dashboard runtime path.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `renderer-consumption-targets-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Renderer consumption inspection written: ${outputFile}`);

console.log(JSON.stringify({ resultCount: report.resultCount, targets: results.map((item) => item.path) }, null, 2));

