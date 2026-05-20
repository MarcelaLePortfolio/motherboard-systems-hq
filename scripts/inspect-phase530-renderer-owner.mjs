
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

const inspectionPatterns = [

  "artifact-preview",

  "semantic-artifact",

  "visual-artifact",

  "innerHTML",

  "insertAdjacentHTML",

  "markdown",

  "preview",

  "render",

  "phase719-preview-modal",

  "phase723SanitizeVisualArtifactHtml",

  "phase735DecodeVisualArtifactHtmlTransport",

];

const findings = [];

for (const pattern of inspectionPatterns) {

  const regex = new RegExp(pattern, "gi");

  let match;

  while ((match = regex.exec(text)) !== null) {

    const start = Math.max(0, match.index - 180);

    const end = Math.min(

      text.length,

      match.index + pattern.length + 180

    );

    findings.push({

      pattern,

      index: match.index,

      context: text.slice(start, end),

    });

  }

}

const grouped = inspectionPatterns.map((pattern) => ({

  pattern,

  count: findings.filter(

    (item) => item.pattern === pattern

  ).length,

}));

const report = {

  schemaVersion:

    "phase736.phase530-renderer-owner-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  grouped,

  findingCount: findings.length,

  findings,

  nextRecommendedStep:

    "Identify exact semantic-card fallback render path before introducing render-native dashboard routing.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `phase530-renderer-owner-inspection-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Phase530 renderer inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile,

      findingCount: findings.length,

      grouped,

    },

    null,

    2

  )

);

