
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

const patchMarker =

  "phase735DecodeVisualArtifactHtmlTransport";

const markerIndex = text.indexOf(patchMarker);

if (markerIndex === -1) {

  console.error(

    `Unable to locate patch marker: ${patchMarker}`

  );

  process.exit(1);

}

const insertionPreview = text.slice(

  Math.max(0, markerIndex - 700),

  Math.min(text.length, markerIndex + 2200)

);

const patchPlan = {

  schemaVersion:

    "phase736.render-native-routing-patch-plan.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  mutationStrategy: {

    approach:

      "Add guarded render-native routing branch before markdown semantic fallback.",

    preserveExistingFallbacks: true,

    preserveSanitizer: true,

    preserveDecodeTransport: true,

    preserveGovernanceBoundaries: true,

    preserveReadOnlyMode: true,

  },

  insertionMarker: patchMarker,

  insertionIndex: markerIndex,

  intendedRoutingBehavior: {

    detectRenderNativePayload: true,

    routeDashboardContracts: true,

    preserveLegacySemanticArtifacts: true,

    preserveMarkdownFallback: true,

  },

  proposedBranchPseudoLogic: [

    "if artifact contains render-native dashboard contract:",

    "  route to renderNativeDashboardRenderer(...)",

    "else:",

    "  continue existing semantic artifact fallback path",

  ],

  extractedContext: insertionPreview,

  riskClassification: {

    level: "controlled",

    rationale:

      "Single guarded insertion branch preserving existing renderer behavior.",

  },

  executionBlocked: true,

  humanApprovalRequired: true,

};

fs.mkdirSync("RENDERER_PATCH_PLANS", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_PATCH_PLANS",

  `render-native-routing-patch-plan-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(patchPlan, null, 2)}\n`

);

console.log(

  `Render-native routing patch plan written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile,

      insertionIndex: markerIndex,

      preserveFallbacks:

        patchPlan.mutationStrategy

          .preserveExistingFallbacks,

      preserveSanitizer:

        patchPlan.mutationStrategy

          .preserveSanitizer,

    },

    null,

    2

  )

);

