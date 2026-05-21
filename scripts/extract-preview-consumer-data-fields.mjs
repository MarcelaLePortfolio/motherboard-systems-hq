
import fs from "fs";

import path from "path";

const targetFile =

  "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget =

  path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text =

  fs.readFileSync(resolvedTarget, "utf8");

const anchorIndex = 61205;

const excerpt =

  text.slice(

    Math.max(0, anchorIndex - 2200),

    Math.min(text.length, anchorIndex + 5200)

  );

const dataFieldRegex =

  /\bdata\.([A-Za-z0-9_$]+)/g;

const fields = [];

let match;

while ((match = dataFieldRegex.exec(excerpt)) !== null) {

  fields.push({

    field: match[1],

    index: match.index,

    context: excerpt.slice(

      Math.max(0, match.index - 350),

      Math.min(excerpt.length, match.index + match[0].length + 700)

    ),

  });

}

const uniqueFields =

  [...new Set(fields.map((item) => item.field))];

const report = {

  schemaVersion:

    "phase736.preview-consumer-data-field-extraction.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  anchorIndex,

  uniqueFields,

  fields,

  recommendation:

    "Use extracted data field reads to define the frontend preview response contract before adding render-native payload routing.",

  mutationBoundary:

    "No mutation performed. Data-field extraction only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `preview-consumer-data-fields-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Preview consumer data fields written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      uniqueFields,

      fieldCount:

        fields.length,

    },

    null,

    2

  )

);

