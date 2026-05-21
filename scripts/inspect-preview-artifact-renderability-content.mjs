
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

const anchorTokens = [

  "template[data-phase735-single-artifact-render]",

  "templateHtml",

  "phase719RenderMarkdownArtifactPreview(data.content)",

  "phase736TryRenderNativeVisualMountPayload(data, templateHtml)",

  "phase735Mount.innerHTML",

];

const findings =

  anchorTokens.map((token) => {

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

        excerpt:

          text.slice(

            Math.max(0, item - 1600),

            Math.min(text.length, item + token.length + 2600)

          ),

      })),

    };

  });

const renderabilitySignals = {

  hasTemplateSelector:

    text.includes("template[data-phase735-single-artifact-render]"),

  hasMarkdownPreview:

    text.includes("phase719RenderMarkdownArtifactPreview(data.content)"),

  hasRenderNativeMountBranch:

    text.includes("phase736TryRenderNativeVisualMountPayload(data, templateHtml)"),

  hasVisualMountAssignment:

    text.includes("phase735Mount.innerHTML"),

  likelyExpectation:

    "render-native branch expects actual template payloads or structured render-native scene objects rather than conceptual prose",

};

const report = {

  schemaVersion:

    "phase736.preview-artifact-renderability-content-inspection.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  renderabilitySignals,

  findings,

  hypothesis:

    "Preview may be blank because generated artifact content lacks actual render-native template structures.",

  likelyReality:

    [

      "renderer corridor is active",

      "mount branch exists",

      "fallback preserved",

      "runtime stable",

      "generated content may not include renderable template payload",

    ],

  nextRecommendedStep:

    "Generate a deliberately explicit render-native payload artifact instead of conceptual design prose and test Preview again before reverting renderer corridor.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `preview-artifact-renderability-content-inspection-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Preview artifact renderability content inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      renderabilitySignals,

      findings: findings.map((finding) => ({

        token: finding.token,

        count: finding.count,

        indexes: finding.indexes,

      })),

    },

    null,

    2

  )

);

