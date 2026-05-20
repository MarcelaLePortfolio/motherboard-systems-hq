
import fs from "fs";

import path from "path";

const targetFile =

  "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

const marker =

  "phase735DecodeVisualArtifactHtmlTransport";

const markerIndex = original.indexOf(marker);

if (markerIndex === -1) {

  console.error(`Unable to locate marker: ${marker}`);

  process.exit(1);

}

if (

  original.includes(

    "phase736RenderNativeDashboardGuard"

  )

) {

  console.log(

    "Render-native routing guard already present."

  );

  process.exit(0);

}

const insertion = `

function phase736RenderNativeDashboardGuard(payload) {

  try {

    if (!payload || typeof payload !== "object") {

      return null;

    }

    const schemaVersion =

      payload.schemaVersion || "";

    const renderMode =

      payload.renderMode || "";

    const rendererTarget =

      payload.rendererTarget || "";

    const isRenderNative =

      schemaVersion.includes("render-native") ||

      renderMode.includes("render-native") ||

      rendererTarget.includes("render-native");

    if (!isRenderNative) {

      return null;

    }

    return {

      renderNative: true,

      payload,

    };

  } catch (error) {

    console.warn(

      "[phase736] render-native guard failed",

      error

    );

    return null;

  }

}

`;

const patched =

  original.slice(0, markerIndex) +

  insertion +

  original.slice(markerIndex);

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      marker,

      insertionIndex: markerIndex,

      insertedGuard:

        "phase736RenderNativeDashboardGuard",

      preserveFallbacks: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

    },

    null,

    2

  )

);

