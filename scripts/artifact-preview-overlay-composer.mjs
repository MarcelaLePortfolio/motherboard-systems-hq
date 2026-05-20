
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function formatCountMap(map = {}) {

  const entries = Object.entries(map);

  if (entries.length === 0) return ["- none"];

  return entries.map(([key, value]) => `- ${key}: ${value}`);

}

function composeOverlay(correlation) {

  const summary = correlation.correlationSummary || {};

  const classificationSummary = correlation.sourceClassification?.classificationSummary || {};

  const sourceDiff = correlation.sourceClassification?.sourceDiff || {};

  const intent = correlation.intent || {};

  const warnings = [];

  if (summary.hasHighRiskUnexpectedChanges) {

    warnings.push("High-risk unexpected changes detected.");

  }

  if (summary.driftDetected) {

    warnings.push("Semantic drift detected between intent and actual artifact changes.");

  }

  if (classificationSummary.hasRuntimeOrInfrastructureChanges) {

    warnings.push("Runtime, infrastructure, or dependency changes require elevated review.");

  }

  if (warnings.length === 0) {

    warnings.push("No elevated warnings detected.");

  }

  return {

    schemaVersion: "phase735.preview-overlay-composition.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    overlayStatus: summary.advisoryStatus || "unknown",

    intent: {

      raw: intent.raw || null,

      expectedSemanticCategories: intent.expectedSemanticCategories || [],

    },

    changeSummary: {

      alignmentScore: summary.alignmentScore ?? null,

      totalActualChanges: summary.totalActualChanges ?? 0,

      matchedChanges: summary.matchedChanges ?? 0,

      matchedCategories: summary.matchedCategories || [],

      unexpectedCategories: summary.unexpectedCategories || [],

      riskCounts: summary.riskCounts || {},

      diffSummary: sourceDiff.summary || {},

    },

    warnings,

    operatorPreviewMarkdown: [

      "# Artifact Preview Overlay",

      "",

      "## Intent",

      intent.raw || "(no intent supplied)",

      "",

      "## Advisory Status",

      summary.advisoryStatus || "unknown",

      "",

      "## Alignment",

      `- Alignment score: ${summary.alignmentScore ?? "unknown"}`,

      `- Total actual changes: ${summary.totalActualChanges ?? 0}`,

      `- Matched changes: ${summary.matchedChanges ?? 0}`,

      "",

      "## Matched Categories",

      ...(summary.matchedCategories?.length ? summary.matchedCategories.map((item) => `- ${item}`) : ["- none"]),

      "",

      "## Unexpected Categories",

      ...(summary.unexpectedCategories?.length ? summary.unexpectedCategories.map((item) => `- ${item}`) : ["- none"]),

      "",

      "## Risk Counts",

      ...formatCountMap(summary.riskCounts || {}),

      "",

      "## Diff Summary",

      ...formatCountMap(sourceDiff.summary || {}),

      "",

      "## Warnings",

      ...warnings.map((warning) => `- ${warning}`),

      "",

      "## Execution Boundary",

      "- This overlay is read-only.",

      "- This overlay does not authorize execution.",

      "- Matilda validation remains required before any mutation authority."

    ].join("\n"),

  };

}

function usage() {

  console.error("Usage: node scripts/artifact-preview-overlay-composer.mjs <intent-correlation-file.json> [output-file.json]");

  process.exit(1);

}

const [correlationFile, outputFile] = process.argv.slice(2);

if (!correlationFile) {

  usage();

}

const correlationPath = path.resolve(correlationFile);

const correlation = readJson(correlationPath);

const overlay = composeOverlay(correlation);

overlay.sourceCorrelation = {

  file: correlationPath,

  schemaVersion: correlation.schemaVersion || null,

  generatedAt: correlation.generatedAt || null,

};

const output = `${JSON.stringify(overlay, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Artifact preview overlay written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

