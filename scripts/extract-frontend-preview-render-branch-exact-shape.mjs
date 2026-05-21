
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const tokens = [

  "data.content",

  "phase735DecodeVisualArtifactHtmlTransport",

  "phase723SanitizeVisualArtifactHtml",

  "innerHTML",

];

const findings = tokens.map((token) => {

  const indexes = [];

  let index = 0;

  while ((index = text.indexOf(token, index)) !== -1) {

    indexes.push(index);

    index += token.length;

  }

  return {

    token,

    count: indexes.length,

    indexes,

    contexts: indexes.map((item) => ({

      index: item,

      excerpt: text.slice(

        Math.max(0, item - 900),

        Math.min(text.length, item + token.length + 1600)

      ),

    })),

  };

});

const report = {

  schemaVersion: "phase736.frontend-preview-render-branch-exact-shape.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  failedAttempt: {

    commit: "92cd4c41",

    reason:

      "frontend render-native branch patch assumed a strict one-line data.content decode/sanitize innerHTML assignment shape",

  },

  findings,

  recommendation:

    "Patch only after exact multi-line branch shape is confirmed from these excerpts.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `frontend-preview-render-branch-exact-shape-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Frontend preview render branch exact shape written: ${outputFile}`);

console.log(JSON.stringify(findings.map(({ token, count, indexes }) => ({ token, count, indexes })), null, 2));

