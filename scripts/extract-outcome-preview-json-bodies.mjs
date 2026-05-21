
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

function extractCallBody(source, startIndex, callToken) {

  const callIndex = source.indexOf(callToken, startIndex);

  if (callIndex === -1) {

    return null;

  }

  const openParen = source.indexOf("(", callIndex);

  if (openParen === -1) {

    return null;

  }

  let depth = 0;

  let endIndex = -1;

  for (let i = openParen; i < source.length; i++) {

    const char = source[i];

    if (char === "(") depth++;

    if (char === ")") depth--;

    if (depth === 0) {

      endIndex = i;

      break;

    }

  }

  if (endIndex === -1) {

    return null;

  }

  return {

    callIndex,

    openParen,

    endIndex,

    callText: source.slice(callIndex, endIndex + 1),

  };

}

const sourceFile = latestFile(

  "RENDERER_INSPECTION",

  "outcome-preview-success-candidate-narrowing-"

);

const source = JSON.parse(fs.readFileSync(sourceFile, "utf8"));

const bodies = (source.ranked || []).map((candidate) => {

  const excerpt = candidate.excerpt || "";

  const body = extractCallBody(excerpt, 0, "res.status(200).json");

  return {

    candidateIndex: candidate.index,

    score: candidate.score,

    routeSignals: candidate.routeSignals,

    bodyFound: Boolean(body),

    body,

  };

});

const report = {

  schemaVersion: "phase736.outcome-preview-json-body-isolation.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceFile,

  targetFile: source.targetFile,

  bodyCount: bodies.filter((item) => item.bodyFound).length,

  bodies,

  recommendation:

    "Compare isolated res.status(200).json(...) bodies and patch only the authoritative preview success response object.",

  mutationBoundary:

    "No mutation performed. Final response-object isolation only.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `outcome-preview-json-body-isolation-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Outcome preview JSON body isolation written: ${outputFile}`);

console.log(

  JSON.stringify(

    {

      bodyCount: report.bodyCount,

      bodies: bodies.map((item) => ({

        candidateIndex: item.candidateIndex,

        score: item.score,

        bodyFound: item.bodyFound,

        bodyPreview: item.body?.callText?.slice(0, 300) || null,

      })),

    },

    null,

    2

  )

);

