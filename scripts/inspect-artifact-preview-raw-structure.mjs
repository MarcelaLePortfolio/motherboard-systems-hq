
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

const contexts = indexes.map((item) => ({

  index: item,

  excerpt: text.slice(

    Math.max(0, item - 3000),

    Math.min(text.length, item + 7000)

  ),

}));

const report = {

  schemaVersion: "phase736.artifact-preview-raw-structure-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  failedAttempt: {

    commit: "45e717d2",

    reason:

      "route boundary extractor assumed router.get/router.post/app.get/app.post but no such marker existed before artifact-preview token",

  },

  token,

  count: indexes.length,

  indexes,

  contexts,

  nextRecommendedStep:

    "Inspect raw structure markers and identify actual route registration style before any mutation.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-raw-structure-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Artifact preview raw structure inspection written: ${outputFile}`);

console.log(JSON.stringify({ targetFile, count: indexes.length, indexes }, null, 2));

