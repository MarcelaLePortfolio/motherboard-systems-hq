
#!/usr/bin/env node

import fs from "fs";

import path from "path";

const REQUIRED_PIPELINE = [

  "snapshot",

  "diff",

  "classification",

  "intent-correlation",

  "preview-overlay",

  "matilda-interpretation",

  "execution-recommendation",

  "human-approval-boundary"

];

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function normalize(value) {

  return String(value || "")

    .trim()

    .toLowerCase();

}

function determineStage(governance) {

  const detected = new Set();

  const recommendation =

    governance?.sourceRecommendation?.schemaVersion || "";

  const governanceSummary =

    governance?.governanceSummary || {};

  if (governanceSummary.pipelineStages) {

    for (const stage of governanceSummary.pipelineStages) {

      detected.add(normalize(stage));

    }

  }

  if (recommendation.includes("recommendation")) {

    detected.add("execution-recommendation");

  }

  detected.add("human-approval-boundary");

  return REQUIRED_PIPELINE.map((stage) => ({

    stage,

    present: detected.has(stage),

  }));

}

function buildReadiness(governance) {

  const stages = determineStage(governance);

  const missingStages = stages

    .filter((stage) => !stage.present)

    .map((stage) => stage.stage);

  const approved =

    governance?.approvalRequired === true &&

    governance?.executionBlocked === true;

  return {

    schemaVersion: "phase735.execution-readiness-gate.v1",

    mode: "read-only",

    generatedAt: new Date().toISOString(),

    readiness: {

      executionReady: approved && missingStages.length === 0,

      approvalRequired: true,

      executionBlockedUntilApproval: true,

      missingStages,

    },

    pipelineStages: stages,

    governanceSource: {

      schemaVersion: governance?.schemaVersion || null,

      generatedAt: governance?.generatedAt || null,

    },

    recommendations: [

      "Maintain human approval boundary before any execution corridor activation.",

      "Preserve read-only enforcement until runtime execution bridge is formally isolated.",

      "Require post-execution reconciliation snapshot validation before state acceptance."

    ]

  };

}

function usage() {

  console.error(

    "Usage: node scripts/execution-readiness-gate.mjs <governance-file.json> [output-file.json]"

  );

  process.exit(1);

}

const [governanceFile, outputFile] = process.argv.slice(2);

if (!governanceFile) {

  usage();

}

const governancePath = path.resolve(governanceFile);

const governance = readJson(governancePath);

const readiness = buildReadiness(governance);

readiness.sourceGovernance = {

  file: governancePath,

  schemaVersion: governance?.schemaVersion || null,

  generatedAt: governance?.generatedAt || null,

};

const output = `${JSON.stringify(readiness, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Execution readiness gate written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

