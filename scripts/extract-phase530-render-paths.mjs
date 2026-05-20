
import fs from "fs";

import path from "path";

const targetFile =

  "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const extractionTargets = [

  "phase723SanitizeVisualArtifactHtml",

  "phase735DecodeVisualArtifactHtmlTransport",

  "visual-artifact",

  "artifact-preview",

  "preview modal",

  "renderPreview",

  "innerHTML",

];

function extractContexts(source, token, radius = 900) {

  const contexts = [];

  let index = 0;

  while ((index = source.indexOf(token, index)) !== -1) {

    const start = Math.max(0, index - radius);

    const end = Math.min(

      source.length,

      index + token.length + radius

    );

    contexts.push({

      token,

      index,

      excerpt: source.slice(start, end),

    });

    index += token.length;

  }

  return contexts;

}

const extracted = extractionTargets.flatMap((token) =>

  extractContexts(text, token)

);

const report = {

  schemaVersion:

    "phase736.phase530-render-path-extraction.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  extractionTargets,

  extractionCount: extracted.length,

  extracted,

  nextRecommendedStep:

    "Identify exact semantic markdown fallback branch and isolate insertion point for render-native dashboard runtime routing.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `phase530-render-path-extraction-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Phase530 render path extraction written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      extractionCount: extracted.length,

      targetFile,

    },

    null,

    2

  )

);

