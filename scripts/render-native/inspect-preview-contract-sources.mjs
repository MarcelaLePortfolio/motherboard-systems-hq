
import { readdirSync, readFileSync, writeFileSync, mkdirSync, statSync } from "node:fs";

import { join } from "node:path";

const roots = [

  "public",

  "routes",

  "server",

  "src",

  "app",

  "scripts",

  "worker",

  "docs"

];

const patterns = [

  "phase719-preview-modal",

  "artifact-preview",

  "Preview",

  "preview",

  "artifact",

  "render"

];

const ignoredDirs = new Set([

  ".git",

  "node_modules",

  ".next",

  "dist",

  "build",

  "coverage",

  "DISASTER_RECOVERY"

]);

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

    if (!stats.isFile()) {

      continue;

    }

    if (stats.size > 500_000) {

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

const groupedFiles = [...new Set(matches.map((match) => match.file))].sort();

const report = {

  schema_version: "phase736.preview-contract-source-inspection.v1",

  corridor: "read-only",

  purpose: "Identify authoritative Preview artifact contract sources before runtime alignment work.",

  inspected_roots: roots,

  searched_patterns: patterns,

  matched_file_count: groupedFiles.length,

  matched_files: groupedFiles,

  matches,

  constraints: {

    live_preview_mutated: false,

    renderer_intercepted: false,

    browser_injected: false,

    runtime_patched: false

  }

};

mkdirSync("scripts/render-native/reports", { recursive: true });

writeFileSync(

  "scripts/render-native/reports/preview-contract-source-inspection.json",

  `${JSON.stringify(report, null, 2)}\n`

);

console.log("PREVIEW CONTRACT SOURCE INSPECTION PASS");

console.log("scripts/render-native/reports/preview-contract-source-inspection.json");

console.log(`Matched files: ${groupedFiles.length}`);

