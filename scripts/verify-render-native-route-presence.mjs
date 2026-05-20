
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

  "phase736TryParseRenderNativeTransport",

  "phase736TryRenderNativeDashboardFromTransport",

  "phase736RenderNativeDashboardHtml(renderNativePayload)",

  "phase736RenderNativeDashboardHtml(",

  "data-phase736-render-native-dashboard",

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

    contexts: indexes.map((item) => ({

      index: item,

      excerpt: text.slice(

        Math.max(0, item - 500),

        Math.min(text.length, item + token.length + 900)

      ),

    })),

  };

});

const routeActive =

  findings.find((item) => item.token === "phase736RenderNativeDashboardHtml(")?.count > 1 ||

  findings.find((item) => item.token === "phase736TryRenderNativeDashboardFromTransport")?.count > 0;

const report = {

  schemaVersion: "phase736.render-native-route-presence-verification.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  routeActive,

  findings,

  conclusion: routeActive

    ? "Render-native route reference appears present; next step should be runtime/browser validation."

    : "Render-native renderer exists but route invocation is not confirmed; patch should not proceed without exact call-site evidence.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `render-native-route-presence-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Render-native route presence verification written: ${outputFile}`);

console.log(JSON.stringify({

  routeActive,

  tokenCounts: findings.map(({ token, count }) => ({ token, count }))

}, null, 2));

