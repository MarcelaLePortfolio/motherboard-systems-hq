
import fs from "node:fs";

import path from "node:path";

const root = process.cwd();

const skipDirs = new Set([".git", "node_modules"]);

const fileNameTerms = [

  "execution",

  "reconcile",

  "diff",

  "snapshot",

  "apply",

  "rollback",

];

const contentChecks = [

  { label: "Matilda references", pattern: /Matilda/g },

  {

    label: "Runtime mutation indicators",

    pattern: /fs\.writeFile|execSync|spawn|docker|kubectl|applyDiff|mutate|executeTask/g,

  },

];

function walk(dir, files = []) {

  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {

    if (skipDirs.has(entry.name)) continue;

    const fullPath = path.join(dir, entry.name);

    if (entry.isDirectory()) {

      walk(fullPath, files);

    } else if (entry.isFile()) {

      files.push(fullPath);

    }

  }

  return files;

}

function relative(filePath) {

  return `./${path.relative(root, filePath)}`;

}

function safeRead(filePath) {

  try {

    return fs.readFileSync(filePath, "utf8");

  } catch {

    return "";

  }

}

const files = walk(root).sort();

console.log("== Execution Bridge Audit ==");

console.log("");

console.log("-- Execution-related infrastructure candidates --");

for (const file of files) {

  const name = path.basename(file).toLowerCase();

  if (fileNameTerms.some((term) => name.includes(term))) {

    console.log(relative(file));

  }

}

for (const check of contentChecks) {

  console.log("");

  console.log(`-- ${check.label} --`);

  for (const file of files) {

    const text = safeRead(file);

    if (!text) continue;

    const lines = text.split(/\r?\n/);

    lines.forEach((line, index) => {

      check.pattern.lastIndex = 0;

      if (check.pattern.test(line)) {

        console.log(`${relative(file)}:${index + 1}:${line.trim()}`);

      }

    });

  }

}

console.log("");

console.log("Execution gap audit complete.");

