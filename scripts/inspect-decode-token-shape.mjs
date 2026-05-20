
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token = "phase735DecodeVisualArtifactHtmlTransport";

const indexes = [];

let index = 0;

while ((index = text.indexOf(token, index)) !== -1) {

  indexes.push(index);

  index += token.length;

}

const contexts = indexes.map((item) => ({

  index: item,

  excerpt: text.slice(

    Math.max(0, item - 900),

    Math.min(text.length, item + token.length + 1400)

  ),

}));

const report = {

  schemaVersion: "phase736.decode-token-shape-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  failedAttemptsInHypothesisClass: 2,

  token,

  count: indexes.length,

  indexes,

  contexts,

  nextRule:

    "One more failed route-activation attempt in this hypothesis class requires rollback to last stable renderer baseline.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `decode-token-shape-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Decode token shape inspection written: ${outputFile}`);

console.log(JSON.stringify({ token, count: indexes.length, indexes }, null, 2));

