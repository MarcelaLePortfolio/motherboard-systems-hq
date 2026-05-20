
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

  "phase736RenderNativePanel",

  "phase735DecodeVisualArtifactHtmlTransport",

  "phase723SanitizeVisualArtifactHtml",

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

        Math.max(0, item - 600),

        Math.min(text.length, item + token.length + 900)

      ),

    })),

  };

});

const report = {

  schemaVersion: "phase736.render-native-guard-location-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  failureContext: {

    failedCommit: "88ab2aa1",

    failedReason: "route activation script could not locate assumed guard invocation snippet",

    actionTaken: "inspect actual guard/helper locations before retrying route activation",

  },

  findings,

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `render-native-guard-location-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Render-native guard location inspection written: ${outputFile}`);

console.log(JSON.stringify(findings.map(({ token, count, indexes }) => ({ token, count, indexes })), null, 2));

