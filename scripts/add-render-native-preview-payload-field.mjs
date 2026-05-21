
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (original.includes("render_native_dashboard")) {

  console.log("Render-native payload field already present.");

  process.exit(0);

}

const artifactPreviewIndex =

  original.indexOf("artifact-preview");

if (artifactPreviewIndex === -1) {

  console.error(

    "Unable to locate artifact-preview route."

  );

  process.exit(1);

}

const resJsonIndex =

  original.indexOf("res.json(", artifactPreviewIndex);

if (resJsonIndex === -1) {

  console.error(

    "Unable to locate preview response payload."

  );

  process.exit(1);

}

const responseObjectStart =

  original.indexOf("{", resJsonIndex);

if (responseObjectStart === -1) {

  console.error(

    "Unable to locate response object start."

  );

  process.exit(1);

}

let depth = 0;

let responseObjectEnd = -1;

for (

  let i = responseObjectStart;

  i < original.length;

  i++

) {

  const char = original[i];

  if (char === "{") depth++;

  if (char === "}") depth--;

  if (depth === 0) {

    responseObjectEnd = i;

    break;

  }

}

if (responseObjectEnd === -1) {

  console.error(

    "Unable to locate response object end."

  );

  process.exit(1);

}

const responseObject =

  original.slice(

    responseObjectStart,

    responseObjectEnd + 1

  );

const insertion = `

,

      render_native_dashboard: {

        enabled: true,

        schema_version:

          "phase736.render-native-dashboard-payload.v1",

        routing_mode:

          "parallel-preview-payload",

        compatibility_mode:

          "legacy-preview-html-preserved",

      }`;

const patchedResponseObject =

  responseObject.replace(

    /\}\s*$/,

    `${insertion}

    }`

  );

if (

  patchedResponseObject === responseObject

) {

  console.error(

    "Failed to inject render-native payload field."

  );

  process.exit(1);

}

const patched =

  original.slice(0, responseObjectStart) +

  patchedResponseObject +

  original.slice(responseObjectEnd + 1);

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      mutation:

        "add render_native_dashboard preview payload field",

      preserveLegacyPreviewHtml: true,

      preserveRendererTransport: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

      mutationBoundary:

        "artifact-preview response payload only",

    },

    null,

    2

  )

);

