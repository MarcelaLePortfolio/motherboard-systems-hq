
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const routeToken = "artifact-preview";

const routeIndex = text.indexOf(routeToken);

if (routeIndex === -1) {

  console.error("Unable to locate artifact-preview route token.");

  process.exit(1);

}

const routeExcerpt = text.slice(

  Math.max(0, routeIndex - 1800),

  Math.min(text.length, routeIndex + 5200)

);

const tokens = [

  "res.json",

  "res.send",

  "res.status",

  "response.json",

  "return",

  "preview",

  "artifact",

  "content",

  "html",

  "rows",

  "query",

];

const findings = tokens.map((token) => {

  const indexes = [];

  let index = 0;

  while ((index = routeExcerpt.indexOf(token, index)) !== -1) {

    indexes.push(index);

    index += token.length;

  }

  return {

    token,

    count: indexes.length,

    indexes,

    contexts: indexes.map((item) => ({

      index: item,

      excerpt: routeExcerpt.slice(

        Math.max(0, item - 350),

        Math.min(routeExcerpt.length, item + token.length + 700)

      ),

    })),

  };

});

const report = {

  schemaVersion: "phase736.artifact-preview-response-method-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  failedAttempt: {

    commit: "168a11bb",

    reason: "script assumed res.json response shape but route did not contain res.json after artifact-preview token",

  },

  routeToken,

  routeIndex,

  routeExcerpt,

  findings,

  nextRecommendedStep:

    "Patch only after the exact response method and payload expression are identified.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-response-methods-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Artifact preview response methods inspection written: ${outputFile}`);

console.log(JSON.stringify(findings.map(({ token, count, indexes }) => ({ token, count, indexes })), null, 2));

