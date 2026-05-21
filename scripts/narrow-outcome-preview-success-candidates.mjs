
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

  "outcome-preview-success-response-branch-"

);

const source = JSON.parse(

  fs.readFileSync(sourceFile, "utf8")

);

const candidates =

  (source.responseCandidates || []).filter(

    (candidate) =>

      candidate.containsOutcomePreview === true

  );

const narrowed = candidates.map((candidate) => {

  const excerpt = candidate.excerpt || "";

  return {

    index: candidate.index,

    containsOutcomePreview:

      candidate.containsOutcomePreview,

    containsRows0:

      candidate.containsRows0,

    containsArtifact:

      candidate.containsArtifact,

    routeSignals: {

      hasArtifactPreviewToken:

        excerpt.includes("artifact-preview"),

      hasOutcomePreviewProjection:

        excerpt.includes(

          "completed.payload->>'outcome_preview'"

        ),

      hasTaskIdParam:

        excerpt.includes("task_id"),

      hasRowsReference:

        excerpt.includes("rows"),

      hasStatus200Json:

        excerpt.includes("res.status(200).json"),

      hasPayloadReference:

        excerpt.includes("payload"),

      hasPreviewReference:

        excerpt.includes("preview"),

    },

    responseShapeLines:

      excerpt

        .split("\n")

        .filter((line) =>

          /res\.status\(200\)|outcome_preview|artifact|preview|payload|rows|task_id/i.test(

            line

          )

        ),

    excerpt,

  };

});

const ranked = narrowed

  .map((candidate) => {

    const signals =

      candidate.routeSignals;

    let score = 0;

    if (signals.hasArtifactPreviewToken) score += 5;

    if (signals.hasStatus200Json) score += 4;

    if (signals.hasOutcomePreviewProjection) score += 4;

    if (signals.hasTaskIdParam) score += 3;

    if (signals.hasRowsReference) score += 2;

    if (signals.hasPayloadReference) score += 2;

    if (signals.hasPreviewReference) score += 1;

    return {

      ...candidate,

      score,

    };

  })

  .sort((a, b) => b.score - a.score);

const report = {

  schemaVersion:

    "phase736.outcome-preview-success-candidate-narrowing.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceFile,

  targetFile: source.targetFile,

  candidateCount:

    narrowed.length,

  ranked,

  recommendation:

    ranked.length === 1

      ? "Single outcome_preview success candidate isolated."

      : "Use highest-scoring candidate only if it has artifact-preview, status(200).json, and outcome_preview signals together.",

  mutationBoundary:

    "No mutation performed. Candidate narrowing only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `outcome-preview-success-candidate-narrowing-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Outcome preview success candidate narrowing written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      candidateCount:

        report.candidateCount,

      ranked:

        ranked.map((candidate) => ({

          index: candidate.index,

          score: candidate.score,

          routeSignals:

            candidate.routeSignals,

        })),

    },

    null,

    2

  )

);

