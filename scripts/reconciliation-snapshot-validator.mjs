import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function summarizeSnapshot(snapshot) {

  return {

    schemaVersion: snapshot.schemaVersion || null,

    generatedAt: snapshot.generatedAt || null,

    artifactCount:

      snapshot.summary?.artifactCount ??

      snapshot.artifactGraph?.length ??

      0,

    repoHead:

      snapshot.repository?.headCommit ||

      snapshot.repository?.gitHead ||

      null,

    branch:

      snapshot.repository?.branch ||

      null,

  };

}

function compareSnapshots(beforeSnapshot, afterSnapshot) {

  const before = summarizeSnapshot(beforeSnapshot);

  const after = summarizeSnapshot(afterSnapshot);

  const checks = {

    artifactCountChanged:

      before.artifactCount !== after.artifactCount,

    repoHeadChanged:

      before.repoHead !== after.repoHead,

    branchChanged:

      before.branch !== after.branch,

  };

  const reconciliationRequired =

    checks.artifactCountChanged ||

    checks.repoHeadChanged ||

    checks.branchChanged;

  return {

    schemaVersion: "phase735.reconciliation-validator.v1",

    mode: "read-only",

    generatedAt: new Date().toISOString(),

    reconciliation: {

      required: reconciliationRequired,

      validated: true,

      status: reconciliationRequired

        ? "state-change-detected"

        : "stable-state-confirmed",

    },

    checks,

    before,

    after,

    recommendations: reconciliationRequired

      ? [

          "Review repository state transitions before accepting execution output.",

          "Generate post-execution artifact diff before reconciliation approval.",

          "Require human confirmation before promoting reconciled state."

        ]

      : [

          "No structural repository divergence detected.",

          "Execution reconciliation baseline remains stable."

        ]

  };

}

function usage() {

  console.error(

    "Usage: node scripts/reconciliation-snapshot-validator.mjs <before-snapshot.json> <after-snapshot.json> [output-file.json]"

  );

  process.exit(1);

}

const [beforeFile, afterFile, outputFile] = process.argv.slice(2);

if (!beforeFile || !afterFile) {

  usage();

}

const beforePath = path.resolve(beforeFile);

const afterPath = path.resolve(afterFile);

const beforeSnapshot = readJson(beforePath);

const afterSnapshot = readJson(afterPath);

const reconciliation = compareSnapshots(

  beforeSnapshot,

  afterSnapshot

);

reconciliation.sourceSnapshots = {

  before: beforePath,

  after: afterPath,

};

const output = `${JSON.stringify(reconciliation, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), {

    recursive: true,

  });

  fs.writeFileSync(resolvedOutput, output);

  console.log(

    `Reconciliation validation written: ${resolvedOutput}`

  );

} else {

  process.stdout.write(output);

}

