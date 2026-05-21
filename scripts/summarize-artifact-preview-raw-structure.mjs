
import fs from "fs";

import path from "path";

function latestFile(dir, prefix) {

  const files = fs

    .readdirSync(dir)

    .filter(

      (file) =>

        file.startsWith(prefix) &&

        file.endsWith(".json")

    )

    .map((file) => path.join(dir, file))

    .sort(

      (a, b) =>

        fs.statSync(b).mtimeMs -

        fs.statSync(a).mtimeMs

    );

  if (!files.length) {

    throw new Error(

      `No matching files for ${prefix}`

    );

  }

  return files[0];

}

const sourceFile = latestFile(

  "RENDERER_INSPECTION",

  "artifact-preview-raw-structure-"

);

const source = JSON.parse(

  fs.readFileSync(sourceFile, "utf8")

);

const summaries = (source.contexts || []).map(

  (context) => {

    const excerpt = context.excerpt || "";

    const lines = excerpt.split("\n");

    return {

      index: context.index,

      lineCount: lines.length,

      firstLines: lines.slice(0, 25),

      routeMarkers: [

        "fastify",

        "server.",

        "router.",

        "app.",

        "get(",

        "post(",

        "register",

        "res.status",

        "reply",

        "ctx",

        "request",

        "response",

        "pool.query",

        "client.query",

      ].map((marker) => ({

        marker,

        count:

          excerpt.split(marker).length - 1,

      })),

      responseLines:

        lines.filter((line) =>

          /res\.status|reply|response|return|json|send|content|artifact|preview/i.test(

            line

          )

        ),

    };

  }

);

const report = {

  schemaVersion:

    "phase736.artifact-preview-raw-structure-summary.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceFile,

  summaries,

  recommendation:

    "Use responseLines and routeMarkers to identify actual route style before mutating payload shape.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-raw-structure-summary-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Artifact preview raw structure summary written: ${outputFile}`

);

console.log(

  JSON.stringify(

    summaries.map((summary) => ({

      index: summary.index,

      lineCount: summary.lineCount,

      routeMarkers:

        summary.routeMarkers.filter(

          (item) => item.count > 0

        ),

      responseLineCount:

        summary.responseLines.length,

      responseLines:

        summary.responseLines.slice(0, 12),

    })),

    null,

    2

  )

);

