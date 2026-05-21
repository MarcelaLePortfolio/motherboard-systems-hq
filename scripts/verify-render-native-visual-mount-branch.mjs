
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const requiredTokens = [

  "function phase736TryParseRenderNativeVisualMountCandidate",

  "function phase736TryRenderNativeVisualMountPayload",

  "phase736RenderNativeVisualMountHtml",

  "phase736TryRenderNativeVisualMountPayload(data, templateHtml)",

  "phase735Mount.innerHTML =",

  "phase723SanitizeVisualArtifactHtml(decoded)",

  "phase735DecodeVisualArtifactHtmlTransport(templateHtml)",

  "phase719RenderMarkdownArtifactPreview(data.content)",

];

const forbiddenRegressionTokens = [

  "phase736RouteDecodedPreviewHtml",

  "phase736TryRenderNativeDashboardFromTransport",

  "phase736TryParseRenderNativeTransport",

];

const requiredFindings = requiredTokens.map((token) => {

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

  };

});

const forbiddenFindings = forbiddenRegressionTokens.map((token) => {

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

  };

});

const branchActive =

  requiredFindings.every((finding) => finding.count > 0);

const noRegressionTokens =

  forbiddenFindings.every((finding) => finding.count === 0);

const markdownPreviewPreserved =

  text.includes("phase719RenderMarkdownArtifactPreview(data.content)");

const decodeTransportPreserved =

  text.includes("phase735DecodeVisualArtifactHtmlTransport(templateHtml)");

const sanitizerFallbackPreserved =

  text.includes("phase723SanitizeVisualArtifactHtml(decoded)");

const report = {

  schemaVersion:

    "phase736.render-native-visual-mount-branch-verification.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  status: {

    branchActive,

    noRegressionTokens,

    markdownPreviewPreserved,

    decodeTransportPreserved,

    sanitizerFallbackPreserved,

    verificationPassed:

      branchActive &&

      noRegressionTokens &&

      markdownPreviewPreserved &&

      decodeTransportPreserved &&

      sanitizerFallbackPreserved,

  },

  requiredFindings,

  forbiddenFindings,

  recommendation:

    "If verification passes, proceed to browser/runtime validation before further renderer mutation.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `render-native-visual-mount-branch-verification-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Render-native visual mount branch verification written: ${outputFile}`

);

console.log(

  JSON.stringify(report.status, null, 2)

);

if (!report.status.verificationPassed) {

  process.exit(1);

}

