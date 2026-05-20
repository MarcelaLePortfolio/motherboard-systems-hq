
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (

  original.includes(

    "phase736RenderNativeDashboardHtml(renderNativePayload)"

  )

) {

  console.log("Preview call-site route already activated.");

  process.exit(0);

}

const token = "phase735DecodeVisualArtifactHtmlTransport(";

const indexes = [];

let searchIndex = 0;

while ((searchIndex = original.indexOf(token, searchIndex)) !== -1) {

  indexes.push(searchIndex);

  searchIndex += token.length;

}

if (indexes.length < 4) {

  console.error(

    `Expected at least 4 decode call-sites, found ${indexes.length}`

  );

  process.exit(1);

}

const targetIndex = indexes[3];

const lineStart = original.lastIndexOf("\n", targetIndex);

const lineEnd = original.indexOf("\n", targetIndex);

if (lineStart === -1 || lineEnd === -1) {

  console.error("Unable to isolate target call-site line.");

  process.exit(1);

}

const originalLine = original.slice(lineStart + 1, lineEnd);

const replacement = `

${originalLine}

      try {

        const phase736RenderNativePayload =

          phase736TryParseRenderNativeTransport(

            typeof artifactHtml === "string"

              ? artifactHtml

              : typeof renderedHtml === "string"

                ? renderedHtml

                : ""

          );

        if (phase736RenderNativePayload) {

          const phase736RenderNativeResult =

            phase736RenderNativeDashboardHtml(

              phase736RenderNativePayload

            );

          if (

            phase736RenderNativeResult &&

            typeof phase736RenderNativeResult === "string"

          ) {

            artifactHtml = phase736RenderNativeResult;

          }

        }

      } catch (error) {

        console.warn(

          "[phase736] preview call-site render-native route fallback",

          error

        );

      }

`;

const patched =

  original.slice(0, lineStart + 1) +

  replacement +

  original.slice(lineEnd);

if (patched === original) {

  console.error("Preview call-site route patch produced no change.");

  process.exit(1);

}

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      activatedRoute: true,

      targetedCallsiteIndex: targetIndex,

      hypothesisClass: "call-site-routing",

      preserveFallbacks: true,

      preservePreviewBehavior: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

      mutationScope: "single preview consumption branch"

    },

    null,

    2

  )

);

