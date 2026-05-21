
import fs from "fs";

import path from "path";

function latestFile(dir, prefix) {

  const files = fs

    .readdirSync(dir)

    .filter((file) =>

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

    throw new Error(`No files found for prefix: ${prefix}`);

  }

  return files[0];

}

const sourceFile = latestFile(

  "RENDERER_INSPECTION",

  "artifact-preview-route-block-"

);

const source = JSON.parse(

  fs.readFileSync(sourceFile, "utf8")

);

const blocks = source.blocks || [];

const patterns = [

  "res.json",

  "return res",

  "artifactHtml",

  "preview",

  "semantic_artifact",

  "visual-artifact",

  "metadata",

  "result",

  "task",

];

const analyses = blocks.map((block) => {

  const excerpt = block.excerpt || "";

  return {

    index: block.index,

    detectedPatterns: patterns.map((pattern) => {

      const indexes = [];

      let index = 0;

      while (

        (index = excerpt.indexOf(pattern, index)) !== -1

      ) {

        indexes.push(index);

        index += pattern.length;

      }

      return {

        pattern,

        count: indexes.length,

        indexes,

      };

    }),

    excerpt,

  };

});

const likelyResponseBlocks = analyses.filter((analysis) => {

  const patternMap = Object.fromEntries(

    analysis.detectedPatterns.map((item) => [

      item.pattern,

      item.count,

    ])

  );

  return (

    patternMap["res.json"] > 0 ||

    patternMap["return res"] > 0

  );

});

const report = {

  schemaVersion:

    "phase736.artifact-preview-response-shape-analysis.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceFile,

  analyses,

  likelyResponseBlocks,

  recommendation:

    "Mutate only the response payload assembly layer by introducing structured render-native metadata fields alongside legacy preview HTML.",

  mutationDiscipline:

    "Do not alter renderer transport, sanitizer, decode, or preview fallback behavior.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-response-shape-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Artifact preview response shape analysis written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      likelyResponseBlockCount:

        likelyResponseBlocks.length,

      indexes:

        likelyResponseBlocks.map(

          (item) => item.index

        ),

    },

    null,

    2

  )

);

