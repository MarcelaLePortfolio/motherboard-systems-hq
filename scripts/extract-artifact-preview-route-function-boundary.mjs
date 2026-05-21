
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token = "artifact-preview";

const tokenIndex = text.indexOf(token);

if (tokenIndex === -1) {

  console.error("Unable to locate artifact-preview token.");

  process.exit(1);

}

let functionStart = -1;

const candidateMarkers = [

  "router.get(",

  "router.post(",

  "app.get(",

  "app.post(",

];

for (const marker of candidateMarkers) {

  const markerIndex =

    text.lastIndexOf(marker, tokenIndex);

  if (markerIndex > functionStart) {

    functionStart = markerIndex;

  }

}

if (functionStart === -1) {

  console.error(

    "Unable to locate route function boundary start."

  );

  process.exit(1);

}

let depth = 0;

let started = false;

let functionEnd = -1;

for (

  let i = functionStart;

  i < text.length;

  i++

) {

  const char = text[i];

  if (char === "{") {

    depth++;

    started = true;

  }

  if (char === "}") {

    depth--;

  }

  if (started && depth === 0) {

    functionEnd = i;

    break;

  }

}

if (functionEnd === -1) {

  console.error(

    "Unable to locate route function boundary end."

  );

  process.exit(1);

}

const extractedRoute =

  text.slice(functionStart, functionEnd + 1);

const signals = [

  "res.status",

  "return",

  "preview",

  "artifact",

  "rows",

  "content",

  "metadata",

  "json",

  "send",

];

const findings = signals.map((signal) => {

  const indexes = [];

  let index = 0;

  while (

    (index = extractedRoute.indexOf(signal, index)) !== -1

  ) {

    indexes.push(index);

    index += signal.length;

  }

  return {

    signal,

    count: indexes.length,

    indexes,

  };

});

const report = {

  schemaVersion:

    "phase736.artifact-preview-route-function-boundary.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  token,

  tokenIndex,

  functionStart,

  functionEnd,

  extractedLength:

    extractedRoute.length,

  findings,

  extractedRoute,

  recommendation:

    "Use the full route boundary to identify the single authoritative success response body before any payload mutation.",

  discipline:

    "No payload mutation performed. Boundary extraction only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-route-function-boundary-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Artifact preview route function boundary written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile,

      functionStart,

      functionEnd,

      extractedLength:

        extractedRoute.length,

      findings:

        findings.map((item) => ({

          signal: item.signal,

          count: item.count,

        })),

    },

    null,

    2

  )

);

