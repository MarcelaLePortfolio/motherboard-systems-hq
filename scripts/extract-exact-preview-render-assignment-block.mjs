
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

const anchorIndex = 62381;

const excerpt =

  text.slice(

    Math.max(0, anchorIndex - 2200),

    Math.min(text.length, anchorIndex + 4200)

  );

const lines =

  excerpt.split("\n");

const relevantLines =

  lines

    .map((line, index) => ({

      lineNumber: index + 1,

      line,

    }))

    .filter(({ line }) =>

      /data\.content|innerHTML|phase723SanitizeVisualArtifactHtml|phase735DecodeVisualArtifactHtmlTransport|artifact|preview/i.test(

        line

      )

    );

const report = {

  schemaVersion:

    "phase736.exact-preview-render-assignment-block.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  anchorIndex,

  excerptLength:

    excerpt.length,

  relevantLines,

  rawExcerpt:

    excerpt,

  recommendation:

    "Use these exact lines to build a structure-aware additive render-native insertion patch instead of regex-only replacement.",

  mutationBoundary:

    "No mutation performed. Exact assignment block extraction only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `exact-preview-render-assignment-block-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Exact preview render assignment block written: ${outputFile}`

);

console.log(

  JSON.stringify(

    relevantLines,

    null,

    2

  )

);

