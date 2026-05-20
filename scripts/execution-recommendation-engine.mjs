
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function buildRecommendation(interpretation) {

  const gate = interpretation.gateDecision || {};

  const assessment = interpretation.semanticAssessment || {};

  const unexpected = assessment.unexpectedCategories || [];

  const warnings = assessment.warnings || [];

  const riskCounts = assessment.riskCounts || {};

  let recommendation = "defer";

  let executionReadiness = "blocked";

  let rollbackRecommended = false;

  let reconciliationPriority = "normal";

  switch (gate.decision) {

    case "no-execution-needed":

      recommendation = "preserve-baseline";

      executionReadiness = "not-required";

      reconciliationPriority = "minimal";

      break;

    case "eligible-for-approval-review":

      recommendation = "candidate-for-controlled-execution";

      executionReadiness = "approval-pending";

      reconciliationPriority = "standard";

      break;

    case "requires-human-review":

      recommendation = "human-review-required";

      executionReadiness = "blocked-pending-review";

      reconciliationPriority = "elevated";

      rollbackRecommended = unexpected.length > 0;

      break;

    case "block-execution":

      recommendation = "rollback-or-containment-review";

      executionReadiness = "hard-blocked";

      reconciliationPriority = "critical";

      rollbackRecommended = true;

      break;

    default:

      recommendation = "manual-analysis-required";

      executionReadiness = "unknown";

      reconciliationPriority = "elevated";

      rollbackRecommended = true;

  }

  return {

    schemaVersion: "phase736.execution-recommendation.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    authorityBoundary: {

      executionAuthorized: false,

      mutationPermitted: false,

      executionBridgePresent: false,

      advisoryOnly: true,

    },

    sourceInterpretation: {

      file: null,

      schemaVersion: interpretation.schemaVersion || null,

      generatedAt: interpretation.generatedAt || null,

    },

    recommendation: {

      recommendation,

      executionReadiness,

      reconciliationPriority,

      rollbackRecommended,

      confidence: gate.confidence || "unknown",

      reason: gate.reason || null,

    },

    reconciliationPlan: {

      preserveCurrentSnapshotBeforeExecution: true,

      requireDiffVerificationBeforeExecution: true,

      requirePostExecutionSnapshot: true,

      requireRollbackPathBeforeMutation: true,

      requireHumanApproval: true,

      recommendedChecks: [

        "semantic-alignment-review",

        "unexpected-category-review",

        "risk-classification-review",

        "snapshot-diff-verification",

      ],

    },

    advisorySignals: {

      warnings,

      unexpectedCategories: unexpected,

      riskCounts,

    },

    executionRecommendationMarkdown: [

      "# Execution Recommendation",

      "",

      "## Recommendation",

      `- Recommendation: ${recommendation}`,

      `- Execution readiness: ${executionReadiness}`,

      `- Reconciliation priority: ${reconciliationPriority}`,

      `- Rollback recommended: ${rollbackRecommended}`,

      "",

      "## Confidence",

      `- ${gate.confidence || "unknown"}`,

      "",

      "## Reason",

      gate.reason || "No reason supplied.",

      "",

      "## Required Reconciliation Checks",

      "- semantic-alignment-review",

      "- unexpected-category-review",

      "- risk-classification-review",

      "- snapshot-diff-verification",

      "",

      "## Authority Boundary",

      "- This layer is advisory-only.",

      "- No execution authority exists.",

      "- Mutation remains blocked.",

      "- Future execution bridge must remain separately governed.",

    ].join("\n"),

  };

}

function usage() {

  console.error("Usage: node scripts/execution-recommendation-engine.mjs <matilda-interpretation-file.json> [output-file.json]");

  process.exit(1);

}

const [interpretationFile, outputFile] = process.argv.slice(2);

if (!interpretationFile) {

  usage();

}

const interpretationPath = path.resolve(interpretationFile);

const interpretation = readJson(interpretationPath);

const recommendation = buildRecommendation(interpretation);

recommendation.sourceInterpretation.file = interpretationPath;

const output = `${JSON.stringify(recommendation, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Execution recommendation written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

