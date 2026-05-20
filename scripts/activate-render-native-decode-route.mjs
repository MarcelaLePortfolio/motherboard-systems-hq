
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (original.includes("phase736TryRenderNativeDashboardFromTransport")) {

  console.log("Render-native decode route already present.");

  process.exit(0);

}

const marker = "function phase735DecodeVisualArtifactHtmlTransport";

const markerIndex = original.indexOf(marker);

if (markerIndex === -1) {

  console.error(`Unable to locate decode function marker: ${marker}`);

  process.exit(1);

}

const functionOpenIndex = original.indexOf("{", markerIndex);

if (functionOpenIndex === -1) {

  console.error("Unable to locate decode function opening brace.");

  process.exit(1);

}

const helperInsertion = `

function phase736TryParseRenderNativeTransport(value) {

  try {

    if (!value || typeof value !== "string") {

      return null;

    }

    const trimmed = value.trim();

    if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {

      return null;

    }

    const parsed = JSON.parse(trimmed);

    const guarded =

      phase736RenderNativeDashboardGuard(parsed);

    if (!guarded || guarded.renderNative !== true) {

      return null;

    }

    return guarded.payload;

  } catch (error) {

    return null;

  }

}

function phase736TryRenderNativeDashboardFromTransport(value) {

  const renderNativePayload =

    phase736TryParseRenderNativeTransport(value);

  if (!renderNativePayload) {

    return null;

  }

  try {

    return phase736RenderNativeDashboardHtml(renderNativePayload);

  } catch (error) {

    console.warn(

      "[phase736] render-native transport route failed, falling back",

      error

    );

    return null;

  }

}

`;

const routeInsertion = `

  const phase736RenderNativeHtml =

    phase736TryRenderNativeDashboardFromTransport(arguments[0]);

  if (

    phase736RenderNativeHtml &&

    typeof phase736RenderNativeHtml === "string"

  ) {

    return phase736RenderNativeHtml;

  }

`;

const patched =

  original.slice(0, markerIndex) +

  helperInsertion +

  original.slice(markerIndex, functionOpenIndex + 1) +

  routeInsertion +

  original.slice(functionOpenIndex + 1);

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      activatedRoute: "phase736TryRenderNativeDashboardFromTransport",

      insertionMarker: marker,

      preserveFallbacks: true,

      preserveExistingDecodeBody: true,

      fallbackBehavior: "If render-native JSON parsing or rendering fails, existing decode/render path continues unchanged"

    },

    null,

    2

  )

);

