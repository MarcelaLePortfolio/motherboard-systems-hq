
import fs from "fs";

import path from "path";

const targetFile =

  "server/routes/api-tasks-postgres.mjs";

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

const token = "outcome_preview";

const indexes = [];

let index = 0;

while (

  (index = text.indexOf(token, index)) !== -1

) {

  indexes.push(index);

  index += token.length;

}

function extractBalancedObject(

  source,

  objectStart

) {

  let depth = 0;

  let inString = false;

  let stringQuote = "";

  let escaping = false;

  for (

    let i = objectStart;

    i < source.length;

    i++

  ) {

    const char = source[i];

    if (escaping) {

      escaping = false;

      continue;

    }

    if (char === "\\") {

      escaping = true;

      continue;

    }

    if (inString) {

      if (char === stringQuote) {

        inString = false;

        stringQuote = "";

      }

      continue;

    }

    if (

      char === '"' ||

      char === "'" ||

      char === "`"

    ) {

      inString = true;

      stringQuote = char;

      continue;

    }

    if (char === "{") depth++;

    if (char === "}") depth--;

    if (depth === 0) {

      return {

        endIndex: i,

        objectText:

          source.slice(

            objectStart,

            i + 1

          ),

      };

    }

  }

  return null;

}

const bodies = indexes.map(

  (tokenIndex) => {

    const searchWindow = text.slice(

      tokenIndex,

      Math.min(

        text.length,

        tokenIndex + 12000

      )

    );

    const statusIndex =

      searchWindow.indexOf(

        "res.status(200).json("

      );

    if (statusIndex === -1) {

      return {

        tokenIndex,

        found: false,

      };

    }

    const absoluteStatusIndex =

      tokenIndex + statusIndex;

    const objectStart =

      text.indexOf(

        "{",

        absoluteStatusIndex

      );

    if (objectStart === -1) {

      return {

        tokenIndex,

        found: false,

        reason:

          "missing response object start",

      };

    }

    const extracted =

      extractBalancedObject(

        text,

        objectStart

      );

    if (!extracted) {

      return {

        tokenIndex,

        found: false,

        reason:

          "unable to balance response object",

      };

    }

    const objectText =

      extracted.objectText;

    return {

      tokenIndex,

      found: true,

      absoluteStatusIndex,

      objectStart,

      objectEnd:

        extracted.endIndex,

      containsOutcomePreview:

        objectText.includes(

          "outcome_preview"

        ),

      containsPayload:

        objectText.includes(

          "payload"

        ),

      containsArtifact:

        /artifact|preview/i.test(

          objectText

        ),

      objectPreview:

        objectText.slice(0, 1200),

      objectText,

    };

  }

);

const report = {

  schemaVersion:

    "phase736.outcome-preview-response-body-search.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  targetFile,

  token,

  tokenCount:

    indexes.length,

  bodies,

  recommendation:

    "Use the first response object that directly contains outcome_preview in the JSON body as the authoritative upstream payload mutation target.",

  mutationBoundary:

    "No mutation performed. Direct response-body search only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile =

  path.join(

    "RENDERER_INSPECTION",

    `outcome-preview-response-body-search-${new Date()

      .toISOString()

      .replace(/[:.]/g, "-")}.json`

  );

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Outcome preview response body search written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      tokenCount:

        report.tokenCount,

      bodies:

        bodies.map((body) => ({

          tokenIndex:

            body.tokenIndex,

          found:

            body.found,

          containsOutcomePreview:

            body.containsOutcomePreview,

          containsPayload:

            body.containsPayload,

          containsArtifact:

            body.containsArtifact,

          objectPreview:

            body.objectPreview?.slice(

              0,

              300

            ) || null,

        })),

    },

    null,

    2

  )

);

