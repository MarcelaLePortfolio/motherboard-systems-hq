
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function buildGovernanceBoundary(recommendation) {

  const rec = recommendation.recommendation || {};

  const advisorySignals = recommendation.advisorySignals || {};

  const requiresElevatedReview =

    rec.executionReadiness === "hard-blocked" ||

    rec.reconciliationPriority === "critical";

  return {

    schemaVersion: "phase736.human-governance-boundary.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    constitutionalBoundary: {

      executionAuthorityDelegated: false,

      autonomousMutationPermitted: false,

      humanApprovalRequired: true,

      rollbackCapabilityRequired: true,

      reconciliationRequired: true,

      advisorySystemOnly: true,

    },

    governanceModel: {

      approvalStates: [

        "draft",

        "review-required",

        "approval-pending",

        "approved",

        "rejected",

        "rollback-required",

        "contained",

      ],

      executionEligibilityRequirements: [

        "verified-artifact-snapshot",

        "verified-diff-analysis",

        "semantic-alignment-review",

        "rollback-path-confirmed",

        "post-execution-reconciliation-plan",

        "human-approval-recorded",

      ],

      mandatoryRollbackRequirements: [

        "pre-execution-snapshot",

        "restorable-checkpoint",

        "rollback-verification-path",

      ],

      containmentTriggers: [

        "unexpected-runtime-modification",

        "high-risk-drift-detection",

        "snapshot-integrity-failure",

        "reconciliation-failure",

      ],

    },

    authorityAssessment: {

      recommendation: rec.recommendation || null,

      executionReadiness: rec.executionReadiness || null,

      rollbackRecommended: rec.rollbackRecommended || false,

      elevatedReviewRequired: requiresElevatedReview,

      warnings: advisorySignals.warnings || [],

      unexpectedCategories: advisorySignals.unexpectedCategories || [],

    },

    governanceDecision: {

      approvalStatus: requiresElevatedReview

        ? "review-required"

        : "approval-pending",

      executionAuthorized: false,

      mutationAuthorized: false,

      nextRequiredAction: requiresElevatedReview

        ? "elevated-human-review"

        : "human-approval-review",

    },

    governanceMarkdown: [

      "# Human Approval & Governance Boundary",

      "",

      "## Constitutional Boundary",

      "- Autonomous mutation is prohibited.",

      "- Human approval is mandatory before execution.",

      "- Rollback capability must exist before mutation.",

      "- Reconciliation is mandatory after execution.",

      "- Advisory cognition does not grant execution authority.",

      "",

      "## Governance Decision",

      `- Approval status: ${

        requiresElevatedReview

          ? "review-required"

          : "approval-pending"

      }`,

      "- Execution authorized: false",

      "- Mutation authorized: false",

      "",

      "## Mandatory Preconditions",

      "- verified-artifact-snapshot",

      "- verified-diff-analysis",

      "- semantic-alignment-review",

      "- rollback-path-confirmed",

      "- post-execution-reconciliation-plan",

      "- human-approval-recorded",

      "",

      "## Containment Triggers",

      "- unexpected-runtime-modification",

      "- high-risk-drift-detection",

      "- snapshot-integrity-failure",

      "- reconciliation-failure",

      "",

      "## Governance Principle",

      "Execution authority must remain structurally separate from advisory cognition.",

    ].join("\n"),

  };

}

function usage() {

  console.error(

    "Usage: node scripts/human-approval-governance-boundary.mjs <execution-recommendation-file.json> [output-file.json]"

  );

  process.exit(1);

}

const [recommendationFile, outputFile] = process.argv.slice(2);

if (!recommendationFile) {

  usage();

}

const recommendationPath = path.resolve(recommendationFile);

const recommendation = readJson(recommendationPath);

const governance = buildGovernanceBoundary(recommendation);

governance.sourceRecommendation = {

  file: recommendationPath,

  schemaVersion: recommendation.schemaVersion || null,

  generatedAt: recommendation.generatedAt || null,

};

const output = `${JSON.stringify(governance, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Governance boundary written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

