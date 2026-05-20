
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function indexArtifacts(snapshot) {

  const index = new Map();

  for (const artifact of snapshot.artifactGraph || []) {

    index.set(artifact.path, artifact);

  }

  return index;

}

function diffSnapshots(beforeSnapshot, afterSnapshot) {

  const beforeIndex = indexArtifacts(beforeSnapshot);

  const afterIndex = indexArtifacts(afterSnapshot);

  const added = [];

  const removed = [];

  const changed = [];

  const unchanged = [];

  for (const [artifactPath, afterArtifact] of afterIndex.entries()) {

    const beforeArtifact = beforeIndex.get(artifactPath);

    if (!beforeArtifact) {

      added.push(afterArtifact);

      continue;

    }

    if (

      beforeArtifact.sha256 !== afterArtifact.sha256 ||

      beforeArtifact.sizeBytes !== afterArtifact.sizeBytes

    ) {

      changed.push({

        path: artifactPath,

        before: beforeArtifact,

        after: afterArtifact,

      });

      continue;

    }

    unchanged.push(afterArtifact);

  }

  for (const [artifactPath, beforeArtifact] of beforeIndex.entries()) {

    if (!afterIndex.has(artifactPath)) {

      removed.push(beforeArtifact);

    }

  }

  return {

    schemaVersion: "phase735.artifact-snapshot-diff.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    before: {

      file: null,

      generatedAt: beforeSnapshot.generatedAt || null,

      branch: beforeSnapshot.repository?.branch || null,

      headCommit: beforeSnapshot.repository?.headCommit || null,

      artifactCount: beforeSnapshot.artifactGraph?.length || 0,

    },

    after: {

      file: null,

      generatedAt: afterSnapshot.generatedAt || null,

      branch: afterSnapshot.repository?.branch || null,

      headCommit: afterSnapshot.repository?.headCommit || null,

      artifactCount: afterSnapshot.artifactGraph?.length || 0,

    },

    summary: {

      added: added.length,

      removed: removed.length,

      changed: changed.length,

      unchanged: unchanged.length,

    },

    changes: {

      added,

      removed,

      changed,

    },

  };

}

function usage() {

  console.error("Usage: node scripts/artifact-snapshot-diff.mjs <before-snapshot.json> <after-snapshot.json> [output-file.json]");

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

const diff = diffSnapshots(beforeSnapshot, afterSnapshot);

diff.before.file = beforePath;

diff.after.file = afterPath;

const output = `${JSON.stringify(diff, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Artifact snapshot diff written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

