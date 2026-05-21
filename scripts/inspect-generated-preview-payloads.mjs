
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

const bridgeText =

  fs.readFileSync(resolvedTarget, "utf8");

const payloadTokens = [

  "render_native_dashboard",

  "renderNativeDashboard",

  "render_native_payload",

  "renderNativePayload",

  "data.content",

  "templateHtml",

  "phase719RenderMarkdownArtifactPreview",

];

const payloadFindings =

  payloadTokens.map((token) => {

    const indexes = [];

    let index = 0;

    while ((index = bridgeText.indexOf(token, index)) !== -1) {

      indexes.push(index);

      index += token.length;

    }

    return {

      token,

      count: indexes.length,

      indexes,

    };

  });

const artifactSnapshotDir =

  path.resolve("ARTIFACT_SNAPSHOTS");

let artifactSnapshots = [];

if (fs.existsSync(artifactSnapshotDir)) {

  artifactSnapshots =

    fs.readdirSync(artifactSnapshotDir)

      .filter((name) => /\.json$/i.test(name))

      .slice(-5);

}

const inspection = {

  schemaVersion:

    "phase736.generated-preview-payload-inspection.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  bridgeFile:

    targetFile,

  payloadFindings,

  artifactSnapshots,

  hypothesis:

    "Blank Preview may be caused by non-renderable conceptual prompt output rather than renderer regression.",

  nextValidationQuestions: [

    "Did the generated artifact contain actual HTML/template payloads?",

    "Did the generated artifact contain render-native JSON structures?",

    "Was the output only conceptual prose/instructions?",

    "Did template[data-phase735-single-artifact-render] exist at runtime?",

    "Did phase736TryRenderNativeVisualMountPayload receive renderable input?",

  ],

  recommendation:

    "Inspect actual generated Preview payload content before reverting renderer branch.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `generated-preview-payload-inspection-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(inspection, null, 2)}\n`

);

console.log(

  `Generated preview payload inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      payloadFindings,

      artifactSnapshots,

    },

    null,

    2

  )

);

