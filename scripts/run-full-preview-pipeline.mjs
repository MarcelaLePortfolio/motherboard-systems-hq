import fs from "fs";

import path from "path";

import { execFileSync } from "child_process";

const repoRoot = process.cwd();

const timestamp = new Date().toISOString().replace(/[:.]/g, "-");

const runDir = path.join(repoRoot, "FULL_PREVIEW_RUNS", `preview-run-${timestamp}`);

const intentText = process.argv.slice(2).join(" ") || "Generate full governed preview pipeline from current artifact state";

function runNode(scriptPath, args = []) {

  return execFileSync("node", [scriptPath, ...args], {

    cwd: repoRoot,

    encoding: "utf8",

    stdio: ["ignore", "pipe", "pipe"],

  }).trim();

}

function latestFile(globDir, prefix, suffix) {

  const files = fs

    .readdirSync(globDir)

    .filter((file) => file.startsWith(prefix) && file.endsWith(suffix))

    .map((file) => path.join(globDir, file))

    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);

  if (!files.length) {

    throw new Error(`No files found in ${globDir} matching ${prefix}*${suffix}`);

  }

  return files[0];

}

fs.mkdirSync(runDir, { recursive: true });

const snapshotBefore = latestFile(

  path.join(repoRoot, "ARTIFACT_SNAPSHOTS"),

  "artifact-snapshot-",

  ".json"

);

runNode("scripts/artifact-snapshot-builder.mjs");

const snapshotAfter = latestFile(

  path.join(repoRoot, "ARTIFACT_SNAPSHOTS"),

  "artifact-snapshot-",

  ".json"

);

const diffFile = path.join(runDir, "01-artifact-diff.json");

const classificationFile = path.join(runDir, "02-diff-classification.json");

const correlationFile = path.join(runDir, "03-intent-correlation.json");

const overlayFile = path.join(runDir, "04-preview-overlay.json");

const interpretationFile = path.join(runDir, "05-matilda-interpretation.json");

const recommendationFile = path.join(runDir, "06-execution-recommendation.json");

const governanceFile = path.join(runDir, "07-human-governance-boundary.json");

const readinessFile = path.join(runDir, "08-execution-readiness.json");

const reconciliationFile = path.join(runDir, "09-reconciliation-validation.json");

runNode("scripts/artifact-snapshot-diff.mjs", [

  snapshotBefore,

  snapshotAfter,

  diffFile,

]);

runNode("scripts/artifact-diff-classifier.mjs", [

  diffFile,

  classificationFile,

]);

runNode("scripts/artifact-intent-correlator.mjs", [

  classificationFile,

  intentText,

  correlationFile,

]);

runNode("scripts/artifact-preview-overlay-composer.mjs", [

  correlationFile,

  overlayFile,

]);

runNode("scripts/matilda-preview-interpreter.mjs", [

  overlayFile,

  interpretationFile,

]);

runNode("scripts/execution-recommendation-engine.mjs", [

  interpretationFile,

  recommendationFile,

]);

runNode("scripts/human-approval-governance-boundary.mjs", [

  recommendationFile,

  governanceFile,

]);

runNode("scripts/execution-readiness-gate.mjs", [

  governanceFile,

  readinessFile,

]);

runNode("scripts/reconciliation-snapshot-validator.mjs", [

  snapshotBefore,

  snapshotAfter,

  reconciliationFile,

]);

const overlay = JSON.parse(fs.readFileSync(overlayFile, "utf8"));

const interpretation = JSON.parse(fs.readFileSync(interpretationFile, "utf8"));

const recommendation = JSON.parse(fs.readFileSync(recommendationFile, "utf8"));

const governance = JSON.parse(fs.readFileSync(governanceFile, "utf8"));

const readiness = JSON.parse(fs.readFileSync(readinessFile, "utf8"));

const reconciliation = JSON.parse(fs.readFileSync(reconciliationFile, "utf8"));

const markdown = [

  "# Full Governed Preview Pipeline Run",

  "",

  `Generated: ${new Date().toISOString()}`,

  `Intent: ${intentText}`,

  "",

  "## Source Snapshots",

  `- Before: ${path.relative(repoRoot, snapshotBefore)}`,

  `- After: ${path.relative(repoRoot, snapshotAfter)}`,

  "",

  "## Preview Overlay",

  overlay.operatorPreviewMarkdown || "(overlay markdown unavailable)",

  "",

  "## Matilda Interpretation",

  interpretation.matildaInterpretationMarkdown || "(interpretation markdown unavailable)",

  "",

  "## Execution Recommendation",

  recommendation.executionRecommendationMarkdown || "(recommendation markdown unavailable)",

  "",

  "## Governance Boundary",

  governance.governanceMarkdown || "(governance markdown unavailable)",

  "",

  "## Readiness Gate",

  "```json",

  JSON.stringify(readiness.readiness || {}, null, 2),

  "```",

  "",

  "## Reconciliation Validation",

  "```json",

  JSON.stringify(reconciliation.reconciliation || {}, null, 2),

  "```",

  "",

  "## Authority Boundary",

  "- This full preview run is read-only.",

  "- This full preview run does not authorize execution.",

  "- Runtime mutation remains blocked.",

  "- Human approval and execution-bridge validation remain mandatory before any future mutation.",

].join("\n");

fs.writeFileSync(path.join(runDir, "FULL_PREVIEW.md"), `${markdown}\n`);

console.log(`Full preview pipeline run written: ${runDir}`);

console.log(`Preview markdown: ${path.join(runDir, "FULL_PREVIEW.md")}`);

