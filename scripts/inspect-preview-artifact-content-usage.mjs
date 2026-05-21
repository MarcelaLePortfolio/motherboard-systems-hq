
import fs from "fs";

import path from "path";

const targetFile =

  "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget =

  path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text =

  fs.readFileSync(resolvedTarget, "utf8");

const anchorIndex = 61205;

const excerpt =

  text.slice(

    Math.max(0, anchorIndex - 2600),

    Math.min(text.length, anchorIndex + 6200)

  );

const tokens = [

  "data.artifact",

  "data.content",

  "data.ok",

  "data.error",

  "artifact",

  "content",

  "innerHTML",

  "phase723SanitizeVisualArtifactHtml",

  "phase735DecodeVisualArtifactHtmlTransport",

  "phase736RenderNativeDashboardGuard",

  "phase736RenderNativeDashboardHtml",

];

const findings =

  tokens.map((token) => {

    const indexes = [];

    let index = 0;

    while ((index = excerpt.indexOf(token, index)) !== -1) {

      indexes.push(index);

      index += token.length;

    }

    return {

      token,

      count: indexes.length,

      indexes,

      contexts:

        indexes.map((item) => ({

          index: item,

          excerpt:

            excerpt.slice(

              Math.max(0, item - 500),

              Math.min(

                excerpt.length,

                item + token.length + 900

              )

            ),

        })),

    };

  });

const report = {

  schemaVersion:

    "phase736.preview-artifact-content-usage-inspection.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  anchorIndex,

  findings,

  recommendation:

    "Identify the smallest optional branch around data.artifact/data.content usage for render-native payload routing without changing the server response contract.",

  mutationBoundary:

    "No mutation performed. Frontend response-field usage inspection only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `preview-artifact-content-usage-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Preview artifact/content usage inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    findings

      .filter((finding) => finding.count > 0)

      .map((finding) => ({

        token: finding.token,

        count: finding.count,

        indexes: finding.indexes,

      })),

    null,

    2

  )

);

