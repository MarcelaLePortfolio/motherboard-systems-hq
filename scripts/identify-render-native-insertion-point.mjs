
import fs from "fs";

import path from "path";

const repoRoot = process.cwd();

function latestFile(dir, prefix) {

  const files = fs

    .readdirSync(dir)

    .filter((file) => file.startsWith(prefix) && file.endsWith(".json"))

    .map((file) => path.join(dir, file))

    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);

  if (!files.length) {

    throw new Error(`No files found in ${dir} matching ${prefix}*.json`);

  }

  return files[0];

}

const extractionFile = latestFile(

  "RENDERER_INSPECTION",

  "phase530-render-path-extraction-"

);

const extraction = JSON.parse(fs.readFileSync(extractionFile, "utf8"));

const scored = extraction.extracted.map((item) => {

  const excerpt = item.excerpt || "";

  let score = 0;

  const reasons = [];

  if (excerpt.includes("phase735DecodeVisualArtifactHtmlTransport")) {

    score += 5;

    reasons.push("contains decode transport path");

  }

  if (excerpt.includes("phase723SanitizeVisualArtifactHtml")) {

    score += 5;

    reasons.push("contains sanitizer path");

  }

  if (excerpt.includes("visual-artifact")) {

    score += 4;

    reasons.push("contains visual artifact path");

  }

  if (excerpt.includes("innerHTML")) {

    score += 3;

    reasons.push("contains DOM write path");

  }

  if (excerpt.includes("preview")) {

    score += 2;

    reasons.push("contains preview path");

  }

  if (excerpt.includes("markdown")) {

    score += 1;

    reasons.push("contains markdown fallback path");

  }

  return {

    token: item.token,

    index: item.index,

    score,

    reasons,

    excerpt,

  };

});

const ranked = scored

  .filter((item) => item.score > 0)

  .sort((a, b) => b.score - a.score || a.index - b.index);

const report = {

  schemaVersion: "phase736.render-native-insertion-point-analysis.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceExtraction: extractionFile,

  targetFile: extraction.targetFile,

  rankedCandidateCount: ranked.length,

  highestConfidenceCandidate: ranked[0] || null,

  rankedCandidates: ranked.slice(0, 10),

  recommendation:

    "Patch only the highest-confidence preview/visual-artifact DOM write branch, preserving sanitizer/decode behavior and default fallback paths.",

  mutationBoundary:

    "No renderer mutation has been performed by this analysis.",

};

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `render-native-insertion-point-analysis-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Insertion point analysis written: ${outputFile}`);

console.log(

  JSON.stringify(

    {

      targetFile: report.targetFile,

      rankedCandidateCount: report.rankedCandidateCount,

      topScore: report.highestConfidenceCandidate?.score || 0,

      topReasons: report.highestConfidenceCandidate?.reasons || [],

    },

    null,

    2

  )

);

