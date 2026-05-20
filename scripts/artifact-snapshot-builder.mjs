
#!/usr/bin/env node

import fs from "fs";

import path from "path";

import crypto from "crypto";

import { execFileSync } from "child_process";

const repoRoot = process.cwd();

const outputDir = path.join(repoRoot, "ARTIFACT_SNAPSHOTS");

const timestamp = new Date().toISOString().replace(/[:.]/g, "-");

const outputFile = path.join(outputDir, `artifact-snapshot-${timestamp}.json`);

function safeExec(command, args = []) {

  try {

    return execFileSync(command, args, {

      cwd: repoRoot,

      encoding: "utf8",

      stdio: ["ignore", "pipe", "pipe"],

    }).trim();

  } catch {

    return null;

  }

}

function hashFile(filePath) {

  const buffer = fs.readFileSync(filePath);

  return crypto.createHash("sha256").update(buffer).digest("hex");

}

function walk(dir, results = []) {

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {

    if (

      entry.name === ".git" ||

      entry.name === "node_modules" ||

      entry.name === ".next" ||

      entry.name === "ARTIFACT_SNAPSHOTS"

    ) {

      continue;

    }

    const fullPath = path.join(dir, entry.name);

    const relativePath = path.relative(repoRoot, fullPath);

    if (entry.isDirectory()) {

      walk(fullPath, results);

    } else {

      const stat = fs.statSync(fullPath);

      results.push({

        path: relativePath,

        sizeBytes: stat.size,

        sha256: hashFile(fullPath),

      });

    }

  }

  return results.sort((a, b) => a.path.localeCompare(b.path));

}

const snapshot = {

  schemaVersion: "phase735.artifact-snapshot.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  repository: {

    root: repoRoot,

    branch: safeExec("git", ["branch", "--show-current"]),

    headCommit: safeExec("git", ["rev-parse", "HEAD"]),

    statusShort: safeExec("git", ["status", "--short"]),

  },

  runtimeAdjacent: {

    dockerPs: safeExec("docker", ["ps", "--format", "{{json .}}"]),

  },

  artifactGraph: walk(repoRoot),

};

fs.mkdirSync(outputDir, { recursive: true });

fs.writeFileSync(outputFile, `${JSON.stringify(snapshot, null, 2)}\n`);

console.log(`Artifact snapshot written: ${outputFile}`);

