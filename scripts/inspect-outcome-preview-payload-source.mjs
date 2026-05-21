
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token = "outcome_preview";

const indexes = [];

let index = 0;

while ((index = text.indexOf(token, index)) !== -1) {

  indexes.push(index);

  index += token.length;

}

const contexts = indexes.map((item) => {

  const excerpt = text.slice(

    Math.max(0, item - 2200),

    Math.min(text.length, item + 5200)

  );

  const markers = [

    "res.status",

    ".json(",

    "return",

    "payload",

    "artifact",

    "preview",

    "rows[0]",

    "completed.payload",

    "SELECT",

    "FROM",

    "task_id",

  ].map((marker) => ({

    marker,

    count:

      excerpt.split(marker).length - 1,

  }));

  return {

    index: item,

    excerptLength: excerpt.length,

    markers,

    excerpt,

  };

});

const report = {

  schemaVersion:

    "phase736.outcome-preview-payload-source-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  token,

  count: indexes.length,

  indexes,

  contexts,

  recommendation:

    "Identify the exact success payload assembly branch fed by outcome_preview before introducing parallel render-native payload metadata.",

  discipline:

    "No mutation performed. Source-payload tracing only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `outcome-preview-payload-source-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Outcome preview payload source inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    contexts.map((context) => ({

      index: context.index,

      excerptLength:

        context.excerptLength,

      markers:

        context.markers.filter(

          (item) => item.count > 0

        ),

    })),

    null,

    2

  )

);

