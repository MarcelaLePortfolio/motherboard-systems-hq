
import fs from "fs";

import path from "path";

const targetFile = "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token = "phase735DecodeVisualArtifactHtmlTransport(";

const indexes = [];

let searchIndex = 0;

while ((searchIndex = text.indexOf(token, searchIndex)) !== -1) {

  indexes.push(searchIndex);

  searchIndex += token.length;

}

if (indexes.length < 4) {

  console.error(

    `Expected at least 4 call-sites, found ${indexes.length}`

  );

  process.exit(1);

}

const targetIndex = indexes[3];

const excerpt = text.slice(

  Math.max(0, targetIndex - 2500),

  Math.min(text.length, targetIndex + 4000)

);

const report = {

  schemaVersion:

    "phase736.preview-callsite-62769-extraction.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  targetIndex,

  token,

  purpose:

    "Extract exact preview consumption branch around strongest render-native routing candidate.",

  hypothesis:

    "This branch likely owns Preview modal HTML assignment/render flow.",

  excerpt,

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `preview-callsite-62769-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Preview call-site extraction written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetIndex,

      excerptLength: excerpt.length,

    },

    null,

    2

  )

);

