
import fs from "fs";

import path from "path";

function latestFile(dir, prefix) {

  const files = fs

    .readdirSync(dir)

    .filter((file) => file.startsWith(prefix) && file.endsWith(".json"))

    .map((file) => path.join(dir, file))

    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);

  if (!files.length) {

    throw new Error(`No matching files for ${prefix}`);

  }

  return files[0];

}

const analysisFile = latestFile(

  "RENDERER_INSPECTION",

  "render-native-insertion-point-analysis-"

);

const analysis = JSON.parse(

  fs.readFileSync(analysisFile, "utf8")

);

const candidate =

  analysis.highestConfidenceCandidate;

if (!candidate) {

  throw new Error("No highest confidence candidate found");

}

const report = {

  schemaVersion:

    "phase736.top-renderer-candidate-extraction.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceAnalysis: analysisFile,

  targetFile: analysis.targetFile,

  score: candidate.score,

  reasons: candidate.reasons,

  token: candidate.token,

  index: candidate.index,

  excerpt: candidate.excerpt,

  interpretation: {

    likelyRendererJunction: true,

    likelyMarkdownFallbackJunction: true,

    likelyDOMWriteBoundary: true,

    likelySafeInsertionZone: true,

  },

  nextRecommendedStep:

    "Manually inspect excerpt and identify smallest conditional routing insertion that preserves existing fallback behavior.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `top-renderer-candidate-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Top renderer candidate extraction written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile: report.targetFile,

      score: report.score,

      reasons: report.reasons,

    },

    null,

    2

  )

);

