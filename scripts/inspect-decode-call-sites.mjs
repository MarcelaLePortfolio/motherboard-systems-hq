
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token = "phase735DecodeVisualArtifactHtmlTransport(";

const findings = [];

let index = 0;

while ((index = text.indexOf(token, index)) !== -1) {

  findings.push({

    index,

    excerpt: text.slice(

      Math.max(0, index - 1200),

      Math.min(text.length, index + token.length + 1800)

    ),

  });

  index += token.length;

}

const classified = findings.map((item) => {

  const excerpt = item.excerpt;

  return {

    index: item.index,

    likelyAssignment:

      excerpt.includes("=") ||

      excerpt.includes("const ") ||

      excerpt.includes("let "),

    likelyInnerHtml:

      excerpt.includes("innerHTML"),

    likelyPreviewPath:

      excerpt.includes("preview"),

    likelyReturnPath:

      excerpt.includes("return "),

    likelySanitizerPath:

      excerpt.includes("phase723SanitizeVisualArtifactHtml"),

    likelyRenderBoundary:

      excerpt.includes("render"),

    excerpt,

  };

});

const report = {

  schemaVersion:

    "phase736.decode-call-site-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  token,

  count: classified.length,

  classified,

  recommendation:

    "Patch the highest-confidence assignment/render call-site instead of patching a nonexistent decode function definition.",

  hypothesisShift:

    "Renderer routing should occur where decoded output is consumed, not where transport helper is referenced.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `decode-call-site-inspection-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Decode call-site inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    classified.map((item) => ({

      index: item.index,

      likelyAssignment: item.likelyAssignment,

      likelyInnerHtml: item.likelyInnerHtml,

      likelyPreviewPath: item.likelyPreviewPath,

      likelyRenderBoundary: item.likelyRenderBoundary,

    })),

    null,

    2

  )

);

