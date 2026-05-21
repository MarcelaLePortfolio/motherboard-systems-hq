
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

const token = "res.status(";

const returns = [];

let index = 0;

while ((index = routeExcerpt.indexOf(token, index)) !== -1) {

  const start = Math.max(0, index - 450);

  const semicolon = routeExcerpt.indexOf(";", index);

  const end =

    semicolon === -1

      ? Math.min(routeExcerpt.length, index + 1200)

      : Math.min(routeExcerpt.length, semicolon + 1);

  returns.push({

    index,

    excerpt: routeExcerpt.slice(start, end),

  });

  index += token.length;

}

const report = {

  schemaVersion:

    "phase736.artifact-preview-status-return-body-extraction.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  routeToken,

  routeIndex,

  returnCount: returns.length,

  returns,

  recommendation:

    "Identify the success response body before adding parallel render-native payload metadata.",

  mutationBoundary:

    "No route mutation performed. This extraction exists to avoid guessing response shape.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-status-return-bodies-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Artifact preview status return bodies written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile,

      returnCount: returns.length,

      indexes: returns.map((item) => item.index),

    },

    null,

    2

  )

);

