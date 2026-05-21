
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

let text = fs.readFileSync(resolvedTarget, "utf8");

const helperMarker = "function phase736RenderNativeDashboardGuard";

if (!text.includes(helperMarker)) {

  console.error(`Unable to locate helper marker: ${helperMarker}`);

  process.exit(1);

}

if (!text.includes("function phase736TryRenderNativeVisualMountPayload")) {

  const helperInsertion = `

function phase736TryParseRenderNativeVisualMountCandidate(candidate) {

  if (!candidate) {

    return null;

  }

  if (typeof candidate === "object") {

    return candidate;

  }

  if (typeof candidate !== "string") {

    return null;

  }

  const trimmed = candidate.trim();

  if (!trimmed || (!trimmed.startsWith("{") && !trimmed.startsWith("["))) {

    return null;

  }

  try {

    return JSON.parse(trimmed);

  } catch (error) {

    return null;

  }

}

function phase736TryRenderNativeVisualMountPayload(data, templateHtml) {

  try {

    const candidates = [

      data?.render_native_dashboard,

      data?.renderNativeDashboard,

      data?.render_native_payload,

      data?.renderNativePayload,

      data?.artifact?.render_native_dashboard,

      data?.artifact?.renderNativeDashboard,

      data?.artifact?.render_native_payload,

      data?.artifact?.renderNativePayload,

      data?.artifact,

      templateHtml,

      data?.content,

    ];

    for (const candidate of candidates) {

      const parsedCandidate =

        phase736TryParseRenderNativeVisualMountCandidate(candidate);

      const guarded =

        phase736RenderNativeDashboardGuard(parsedCandidate);

      if (!guarded || guarded.renderNative !== true) {

        continue;

      }

      const rendered =

        phase736RenderNativeDashboardHtml(guarded.payload);

      if (rendered && typeof rendered === "string") {

        return rendered;

      }

    }

    return null;

  } catch (error) {

    console.warn(

      "[phase736] render-native visual mount route failed, falling back",

      error

    );

    return null;

  }

}

`;

  text = text.replace(

    helperMarker,

    `${helperInsertion}${helperMarker}`

  );

}

const legacyLine =

  "          phase735Mount.innerHTML = phase723SanitizeVisualArtifactHtml(decoded);";

const replacementBlock = `          const phase736RenderNativeVisualMountHtml =

            phase736TryRenderNativeVisualMountPayload(data, templateHtml);

          phase735Mount.innerHTML =

            phase736RenderNativeVisualMountHtml ||

            phase723SanitizeVisualArtifactHtml(decoded);`;

if (!text.includes(legacyLine)) {

  console.error("Unable to locate visual mount legacy sanitizer assignment.");

  process.exit(1);

}

if (!text.includes("phase736RenderNativeVisualMountHtml")) {

  text = text.replace(

    legacyLine,

    replacementBlock

  );

}

fs.writeFileSync(resolvedTarget, text);

console.log(

  JSON.stringify(

    {

      targetFile,

      activatedBranch:

        "phase736TryRenderNativeVisualMountPayload",

      mutationBoundary:

        "visual artifact mount branch only",

      preserveMarkdownPreview: true,

      preserveLegacyVisualMount: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

      fallbackBehavior:

        "legacy decoded/sanitized visual artifact mount remains fallback",

    },

    null,

    2

  )

);

