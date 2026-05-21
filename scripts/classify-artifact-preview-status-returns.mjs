
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

  "artifact-preview-status-return-bodies-"

);

const source = JSON.parse(

  fs.readFileSync(sourceFile, "utf8")

);

const classifiedReturns =

  (source.returns || []).map((item) => {

    const excerpt = item.excerpt || "";

    const lower = excerpt.toLowerCase();

    let classification = "unknown";

    const signals = [];

    if (

      lower.includes("404") ||

      lower.includes("not found")

    ) {

      classification = "error";

      signals.push("not-found");

    }

    if (

      lower.includes("400") ||

      lower.includes("bad request")

    ) {

      classification = "error";

      signals.push("bad-request");

    }

    if (

      lower.includes("500") ||

      lower.includes("error")

    ) {

      classification = "error";

      signals.push("server-error");

    }

    if (

      lower.includes("200") ||

      lower.includes("content") ||

      lower.includes("artifact") ||

      lower.includes("preview")

    ) {

      if (classification !== "error") {

        classification = "candidate-success";

      }

      signals.push("preview-content");

    }

    if (

      lower.includes("rows[0]") ||

      lower.includes("rows?.[0]") ||

      lower.includes("row")

    ) {

      signals.push("database-row");

    }

    if (

      lower.includes("res.status(200)") ||

      lower.includes("status(200)")

    ) {

      classification = "success";

      signals.push("explicit-200");

    }

    return {

      index: item.index,

      classification,

      signals,

      excerpt,

    };

  });

const successCandidates =

  classifiedReturns.filter((item) =>

    ["success", "candidate-success"].includes(

      item.classification

    )

  );

const report = {

  schemaVersion:

    "phase736.artifact-preview-status-return-classification.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceFile,

  targetFile: source.targetFile,

  classifiedReturns,

  successCandidateCount:

    successCandidates.length,

  successCandidates,

  recommendation:

    successCandidates.length === 1

      ? "Patch the single success response body with parallel render-native payload metadata."

      : "Do not patch yet. Multiple or zero success candidates require narrower extraction.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-status-return-classification-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Artifact preview status return classification written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      successCandidateCount:

        report.successCandidateCount,

      classified:

        classifiedReturns.map((item) => ({

          index: item.index,

          classification:

            item.classification,

          signals: item.signals,

        })),

    },

    null,

    2

  )

);

