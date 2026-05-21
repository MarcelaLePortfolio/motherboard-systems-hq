
import fs from "fs";

import path from "path";

const targetFile =

  "public/js/phase530_visible_panels_bridge.js";

const resolvedTarget =

  path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(

    `Missing target file: ${resolvedTarget}`

  );

  process.exit(1);

}

const text =

  fs.readFileSync(resolvedTarget, "utf8");

const token = "artifact-preview";

const indexes = [];

let index = 0;

while (

  (index = text.indexOf(token, index)) !== -1

) {

  indexes.push(index);

  index += token.length;

}

const contexts =

  indexes.map((item) => {

    const excerpt =

      text.slice(

        Math.max(0, item - 1800),

        Math.min(

          text.length,

          item + 4200

        )

      );

    const markers =

      [

        "fetch(",

        ".json()",

        "await",

        "response",

        "data.",

        "preview",

        "artifact",

        "content",

        "html",

        "payload",

        "outcome",

        "innerHTML",

        "phase719-preview-modal",

      ].map((marker) => ({

        marker,

        count:

          excerpt.split(marker).length - 1,

      }));

    return {

      index: item,

      excerptLength:

        excerpt.length,

      markers,

      excerpt,

    };

  });

const report = {

  schemaVersion:

    "phase736.preview-fetch-consumer-contexts.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  token,

  count:

    indexes.length,

  contexts,

  recommendation:

    "Identify the exact response data field consumed by Preview before adding render-native payload routing.",

  mutationBoundary:

    "No mutation performed. Fetch consumer context extraction only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `preview-fetch-consumer-contexts-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Preview fetch consumer contexts written: ${outputFile}`

);

console.log(

  JSON.stringify(

    contexts.map((context) => ({

      index:

        context.index,

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

