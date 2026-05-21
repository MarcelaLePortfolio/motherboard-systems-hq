
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const token =

  "completed.payload->>'outcome_preview' AS outcome_preview";

const tokenIndex = text.indexOf(token);

if (tokenIndex === -1) {

  console.error(

    "Unable to locate outcome_preview SQL projection."

  );

  process.exit(1);

}

const excerpt = text.slice(

  Math.max(0, tokenIndex - 3500),

  Math.min(text.length, tokenIndex + 9500)

);

const markers = [

  "SELECT",

  "FROM",

  "rows[0]",

  "res.status(200)",

  ".json(",

  "outcome_preview",

  "artifact",

  "preview",

  "payload",

  "return",

];

const findings = markers.map((marker) => {

  const indexes = [];

  let index = 0;

  while (

    (index = excerpt.indexOf(marker, index)) !== -1

  ) {

    indexes.push(index);

    index += marker.length;

  }

  return {

    marker,

    count: indexes.length,

    indexes,

  };

});

const responseCandidates = [];

const successToken = "res.status(200).json(";

let responseIndex = 0;

while (

  (responseIndex = excerpt.indexOf(

    successToken,

    responseIndex

  )) !== -1

) {

  const responseExcerpt = excerpt.slice(

    Math.max(0, responseIndex - 900),

    Math.min(

      excerpt.length,

      responseIndex + 2400

    )

  );

  responseCandidates.push({

    index: responseIndex,

    containsOutcomePreview:

      responseExcerpt.includes(

        "outcome_preview"

      ),

    containsRows0:

      responseExcerpt.includes("rows[0]"),

    containsArtifact:

      /artifact|preview|payload/i.test(

        responseExcerpt

      ),

    excerpt: responseExcerpt,

  });

  responseIndex += successToken.length;

}

const report = {

  schemaVersion:

    "phase736.outcome-preview-success-response-branch.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  token,

  tokenIndex,

  excerptLength:

    excerpt.length,

  findings,

  responseCandidates,

  recommendation:

    "Patch only the res.status(200).json(...) success branch that directly consumes outcome_preview or rows[0].",

  discipline:

    "No mutation performed. Success response isolation only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `outcome-preview-success-response-branch-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Outcome preview success response branch written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      tokenIndex,

      responseCandidateCount:

        responseCandidates.length,

      candidates:

        responseCandidates.map(

          (candidate) => ({

            index: candidate.index,

            containsOutcomePreview:

              candidate.containsOutcomePreview,

            containsRows0:

              candidate.containsRows0,

            containsArtifact:

              candidate.containsArtifact,

          })

        ),

    },

    null,

    2

  )

);

