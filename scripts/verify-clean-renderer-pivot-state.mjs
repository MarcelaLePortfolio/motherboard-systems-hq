
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const tokens = [

  "phase736RenderNativeDashboardGuard",

  "phase736RenderNativeDashboardHtml",

  "phase736RouteDecodedPreviewHtml",

  "phase736TryParseRenderNativeTransport",

  "phase736TryRenderNativeDashboardFromTransport",

  "phase736RenderNativeDashboardHtml(renderNativePayload)",

  "data-phase736-render-native-dashboard",

  "phase723SanitizeVisualArtifactHtml",

  "phase735DecodeVisualArtifactHtmlTransport",

];

const findings = tokens.map((token) => {

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

const routeActivationTokens = [

  "phase736RouteDecodedPreviewHtml",

  "phase736TryParseRenderNativeTransport",

  "phase736TryRenderNativeDashboardFromTransport",

];

const activeRouteTokenCount = findings

  .filter((item) => routeActivationTokens.includes(item.token))

  .reduce((sum, item) => sum + item.count, 0);

const guardPresent =

  findings.find((item) => item.token === "phase736RenderNativeDashboardGuard")?.count > 0;

const rendererPresent =

  findings.find((item) => item.token === "phase736RenderNativeDashboardHtml")?.count > 0;

const routeInactive = activeRouteTokenCount === 0;

const report = {

  schemaVersion: "phase736.clean-renderer-pivot-state-verification.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  status: {

    guardPresent,

    rendererPresent,

    routeInactive,

    cleanPivotConfirmed: guardPresent && rendererPresent && routeInactive,

  },

  findings,

  conclusion:

    guardPresent && rendererPresent && routeInactive

      ? "Clean pivot state confirmed: renderer-native guard and renderer are present, speculative route activation is absent."

      : "Clean pivot state not fully confirmed; inspect findings before continuing.",

  nextRecommendedStep:

    "Begin upstream structured render-native payload routing instead of legacy decode/sanitizer expression patching.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `clean-renderer-pivot-state-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Clean renderer pivot verification written: ${outputFile}`);

console.log(JSON.stringify(report.status, null, 2));

