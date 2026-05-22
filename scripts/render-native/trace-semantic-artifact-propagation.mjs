
import { readdirSync, readFileSync, writeFileSync, mkdirSync, statSync } from "node:fs";

import { join } from "node:path";

const roots = [

  "server",

  "worker",

  "public/js",

  "scripts",

  "src",

  "app",

  "routes"

];

const patterns = [

  "semantic_artifact",

  "artifact_kind",

  "semantic-artifact.v1",

  "sections",

  "outcome_preview",

  "artifact-preview",

  "api/tasks"

];

const ignoredDirs = new Set([

  ".git",

  "node_modules",

  ".next",

  "dist",

  "build",

  "coverage",

  "DISASTER_RECOVERY",

  "runtime-captures",

  "snapshots"

]);

const allowedExtensions = [

  ".js",

  ".mjs",

  ".cjs",

  ".ts",

  ".tsx",

  ".jsx",

  ".json"

];

function allowed(path) {

  return allowedExtensions.some((extension) => path.endsWith(extension));

}

const matches = [];

function walk(dir) {

  let entries = [];

  try {

    entries = readdirSync(dir);

  } catch {

    return;

  }

  for (const entry of entries) {

    const path = join(dir, entry);

    let stats;

    try {

      stats = statSync(path);

    } catch {

      continue;

    }

    if (stats.isDirectory()) {

      if (!ignoredDirs.has(entry)) {

        walk(path);

      }

      continue;

    }

    if (!stats.isFile() || !allowed(path) || stats.size > 400_000) {

      continue;

    }

    let text = "";

    try {

      text = readFileSync(path, "utf8");

    } catch {

      continue;

    }

    const lines = text.split("\n");

    lines.forEach((line, index) => {

      for (const pattern of patterns) {

        if (line.includes(pattern)) {

          matches.push({

            file: path,

            line: index + 1,

            pattern,

            text: line.trim()

          });

        }

      }

    });

  }

}

for (const root of roots) {

  try {

    if (statSync(root).isDirectory()) {

      walk(root);

    }

  } catch {

    continue;

  }

}

const files = [...new Set(matches.map((match) => match.file))].sort();

const report = {

  schema_version: "phase736.semantic-artifact-propagation-trace.v1",

  corridor: "read-only-lifecycle-tracing",

  purpose: "Trace where semantic artifact structure is created, stored, transformed, or dropped before Preview route emission.",

  inspected_roots: roots,

  searched_patterns: patterns,

  matched_file_count: files.length,

  matched_files: files,

  matches,

  constraints: {

    runtime_mutated: false,

    live_preview_mutated: false,

    renderer_intercepted: false,

    browser_injected: false

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(

  "scripts/render-native/reports/semantic-artifact-propagation-trace.json",

  `${JSON.stringify(report, null, 2)}\n`

);

console.log("SEMANTIC ARTIFACT PROPAGATION TRACE PASS");

console.log("scripts/render-native/reports/semantic-artifact-propagation-trace.json");

console.log(`Matched files: ${files.length}`);

