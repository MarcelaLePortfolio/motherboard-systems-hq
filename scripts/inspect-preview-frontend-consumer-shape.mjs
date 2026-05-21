
import fs from "fs";

import path from "path";

const targetFile =

  "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget =

  path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(

    `Missing target file: ${resolvedTarget}`

  );

  process.exit(1);

}

const text =

  fs.readFileSync(resolvedTarget, "utf8");

const tokens = [

  "artifact-preview",

  "fetch(",

  ".json()",

  "response",

  "preview",

  "artifact",

  "content",

  "html",

  "outcome",

  "payload",

  "phase719-preview-modal",

  "innerHTML",

];

const findings =

  tokens.map((token) => {

    const indexes = [];

    let index = 0;

    while (

      (index = text.indexOf(token, index)) !== -1

    ) {

      indexes.push(index);

      index += token.length;

    }

    return {

      token,

      count: indexes.length,

      indexes,

      contexts:

        indexes.slice(0, 10).map((item) => ({

          index: item,

          excerpt:

            text.slice(

              Math.max(0, item - 900),

              Math.min(

                text.length,

                item + token.length + 1600

              )

            ),

        })),

    };

  });

const artifactPreviewContexts =

  findings.find(

    (item) => item.token === "artifact-preview"

  )?.contexts || [];

const report = {

  schemaVersion:

    "phase736.preview-frontend-consumer-shape-inspection.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  findings,

  artifactPreviewContexts,

  recommendation:

    "Identify what frontend expects from /artifact-preview before deciding whether to shape server response or frontend consumer.",

  mutationBoundary:

    "No mutation performed. Frontend consumer inspection only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `preview-frontend-consumer-shape-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Preview frontend consumer shape inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile,

      strongestSignals:

        findings

          .filter((finding) => finding.count > 0)

          .map((finding) => ({

            token:

              finding.token,

            count:

              finding.count,

          })),

      artifactPreviewContextCount:

        artifactPreviewContexts.length,

    },

    null,

    2

  )

);

