
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function determineGateDecision(overlay) {

  const status = overlay.overlayStatus || "unknown";

  const warnings = overlay.warnings || [];

  const changeSummary = overlay.changeSummary || {};

  const unexpectedCategories = changeSummary.unexpectedCategories || [];

  const riskCounts = changeSummary.riskCounts || {};

  const hasHighRisk = Boolean(riskCounts.high);

  const hasUnexpected = unexpectedCategories.length > 0;

  const hasWarnings = warnings.some((warning) => warning !== "No elevated warnings detected.");

  if (status === "no-change-baseline") {

    return {

      decision: "no-execution-needed",

      confidence: "high",

      reason: "No artifact changes were detected; execution is unnecessary.",

    };

  }

  if (hasHighRisk) {

    return {

      decision: "block-execution",

      confidence: "high",

      reason: "High-risk changes require explicit elevated review before execution.",

    };

  }

  if (hasUnexpected || hasWarnings || status === "requires-review") {

    return {

      decision: "requires-human-review",

      confidence: "medium",

      reason: "Unexpected categories or advisory warnings require operator review.",

    };

  }

  if (status === "aligned") {

    return {

      decision: "eligible-for-approval-review",

      confidence: "medium",

      reason: "Changes appear aligned, but Matilda interpretation does not authorize execution by itself.",

    };

  }

  return {

    decision: "requires-human-review",

    confidence: "low",

    reason: "Overlay status is unknown or insufficiently classified.",

  };

}

function interpretOverlay(overlay) {

  const gate = determineGateDecision(overlay);

  const changeSummary = overlay.changeSummary || {};

  return {

    schemaVersion: "phase735.matilda-preview-interpretation.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    authorityBoundary: {

      matildaRole: "semantic-validation-gate",

      executionAuthorized: false,

      mutationPermitted: false,

      requiresHumanApprovalBeforeExecution: true,

    },

    sourceOverlay: {

      file: null,

      schemaVersion: overlay.schemaVersion || null,

      generatedAt: overlay.generatedAt || null,

      overlayStatus: overlay.overlayStatus || null,

      sourceCorrelation: overlay.sourceCorrelation || null,

    },

    semanticAssessment: {

      intent: overlay.intent || null,

      alignmentScore: changeSummary.alignmentScore ?? null,

      totalActualChanges: changeSummary.totalActualChanges ?? 0,

      matchedChanges: changeSummary.matchedChanges ?? 0,

      matchedCategories: changeSummary.matchedCategories || [],

      unexpectedCategories: changeSummary.unexpectedCategories || [],

      riskCounts: changeSummary.riskCounts || {},

      warnings: overlay.warnings || [],

    },

    gateDecision: gate,

    matildaInterpretationMarkdown: [

      "# Matilda Preview Interpretation",

      "",

      "## Gate Decision",

      `- Decision: ${gate.decision}`,

      `- Confidence: ${gate.confidence}`,

      `- Reason: ${gate.reason}`,

      "",

      "## Authority Boundary",

      "- This interpretation is read-only.",

      "- This interpretation does not authorize execution.",

      "- Runtime mutation remains blocked until explicit approval and execution-bridge validation exist.",

      "",

      "## Semantic Assessment",

      `- Alignment score: ${changeSummary.alignmentScore ?? "unknown"}`,

      `- Total actual changes: ${changeSummary.totalActualChanges ?? 0}`,

      `- Matched changes: ${changeSummary.matchedChanges ?? 0}`,

      "",

      "## Unexpected Categories",

      ...(changeSummary.unexpectedCategories?.length

        ? changeSummary.unexpectedCategories.map((category) => `- ${category}`)

        : ["- none"]),

      "",

      "## Warnings",

      ...(overlay.warnings?.length ? overlay.warnings.map((warning) => `- ${warning}`) : ["- none"]),

    ].join("\n"),

  };

}

function usage() {

  console.error("Usage: node scripts/matilda-preview-interpreter.mjs <preview-overlay-file.json> [output-file.json]");

  process.exit(1);

}

const [overlayFile, outputFile] = process.argv.slice(2);

if (!overlayFile) {

  usage();

}

const overlayPath = path.resolve(overlayFile);

const overlay = readJson(overlayPath);

const interpretation = interpretOverlay(overlay);

interpretation.sourceOverlay.file = overlayPath;

const output = `${JSON.stringify(interpretation, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Matilda preview interpretation written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

