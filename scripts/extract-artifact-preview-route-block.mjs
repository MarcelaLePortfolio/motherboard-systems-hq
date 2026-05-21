
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token = "artifact-preview";

const indexes = [];

let index = 0;

while ((index = text.indexOf(token, index)) !== -1) {

  indexes.push(index);

  index += token.length;

}

const blocks = indexes.map((item) => ({

  index: item,

  excerpt: text.slice(

    Math.max(0, item - 2200),

    Math.min(text.length, item + token.length + 3600)

  ),

}));

const report = {

  schemaVersion: "phase736.artifact-preview-route-block-extraction.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  token,

  count: indexes.length,

  indexes,

  blocks,

  recommendation:

    "Use this extracted route block to identify the exact response object where render-native payload metadata can be added upstream.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-route-block-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Artifact preview route block extraction written: ${outputFile}`);

console.log(JSON.stringify({ targetFile, count: indexes.length, indexes }, null, 2));

