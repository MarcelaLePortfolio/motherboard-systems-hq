
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const original = fs.readFileSync(resolvedTarget, "utf8");

if (original.includes("phase736TryRenderNativePreviewPayload")) {

  console.log("Frontend render-native preview branch already present.");

  process.exit(0);

}

const helperMarker = "function phase736RenderNativeDashboardGuard";

const helperMarkerIndex = original.indexOf(helperMarker);

if (helperMarkerIndex === -1) {

  console.error(`Unable to locate helper marker: ${helperMarker}`);

  process.exit(1);

}

const legacyPattern =

  /([A-Za-z0-9_$.[\]]+\.innerHTML\s*=\s*)phase723SanitizeVisualArtifactHtml\(\s*phase735DecodeVisualArtifactHtmlTransport\(\s*data\.content\s*\)\s*\)\s*;/;

const legacyMatch = original.match(legacyPattern);

if (!legacyMatch) {

  console.error("Unable to locate legacy data.content decode/sanitize innerHTML branch.");

  process.exit(1);

}

const helperInsertion = `

function phase736TryParseRenderNativeCandidate(candidate) {

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

function phase736TryRenderNativePreviewPayload(data) {

  try {

    if (!data || typeof data !== "object") {

      return null;

    }

    const candidates = [

      data.render_native_dashboard,

      data.renderNativeDashboard,

      data.render_native_payload,

      data.renderNativePayload,

      data.artifact?.render_native_dashboard,

      data.artifact?.renderNativeDashboard,

      data.artifact?.render_native_payload,

      data.artifact?.renderNativePayload,

      data.artifact,

      data.content,

    ];

    for (const candidate of candidates) {

      const parsedCandidate =

        phase736TryParseRenderNativeCandidate(candidate);

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

      "[phase736] render-native preview payload route failed, falling back",

      error

    );

    return null;

  }

}

`;

const legacyAssignmentPrefix = legacyMatch[1];

const replacement = `const phase736RenderNativePreviewHtml =

      phase736TryRenderNativePreviewPayload(data);

    ${legacyAssignmentPrefix}phase736RenderNativePreviewHtml ||

      phase723SanitizeVisualArtifactHtml(

        phase735DecodeVisualArtifactHtmlTransport(data.content)

      );`;

const withHelper =

  original.slice(0, helperMarkerIndex) +

  helperInsertion +

  original.slice(helperMarkerIndex);

const patched = withHelper.replace(legacyPattern, replacement);

if (patched === withHelper) {

  console.error("Frontend render-native preview branch patch produced no change.");

  process.exit(1);

}

fs.writeFileSync(resolvedTarget, patched);

console.log(

  JSON.stringify(

    {

      targetFile,

      activatedBranch: "phase736TryRenderNativePreviewPayload",

      mutationBoundary: "frontend Preview consumer branch only",

      preserveLegacyDataContent: true,

      preserveSanitizer: true,

      preserveDecodeTransport: true,

      fallbackBehavior: "legacy data.content decode/sanitize innerHTML branch remains fallback",

    },

    null,

    2

  )

);

