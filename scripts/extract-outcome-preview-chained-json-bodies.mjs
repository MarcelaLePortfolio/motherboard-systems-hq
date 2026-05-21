
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

    throw new Error(`No matching files for ${prefix}`);

  }

  return files[0];

}

function extractChainedJsonCall(source, startIndex) {

  const callToken = "res.status(200).json";

  const callIndex = source.indexOf(callToken, startIndex);

  if (callIndex === -1) {

    return null;

  }

  const jsonParen = source.indexOf("(", callIndex + callToken.length);

  if (jsonParen === -1) {

    return null;

  }

  let depth = 0;

  let endIndex = -1;

  let inString = false;

  let stringQuote = "";

  let escaping = false;

  for (let i = jsonParen; i < source.length; i++) {

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

    if (char === '"' || char === "'" || char === "`") {

      inString = true;

      stringQuote = char;

      continue;

    }

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

  const semicolonIndex = source.indexOf(";", endIndex);

  return {

    callIndex,

    jsonParen,

    endIndex,

    semicolonIndex,

    callText: source.slice(

      callIndex,

      semicolonIndex === -1 ? endIndex + 1 : semicolonIndex + 1

    ),

    jsonArgument: source.slice(jsonParen + 1, endIndex),

  };

}

const sourceFile = latestFile(

  "RENDERER_INSPECTION",

  "outcome-preview-success-candidate-narrowing-"

);

const source = JSON.parse(

  fs.readFileSync(sourceFile, "utf8")

);

const bodies =

  (source.ranked || []).map((candidate) => {

    const excerpt = candidate.excerpt || "";

    const body = extractChainedJsonCall(excerpt, 0);

    return {

      candidateIndex: candidate.index,

      score: candidate.score,

      routeSignals: candidate.routeSignals,

      bodyFound: Boolean(body),

      body,

      containsRenderNativePayload:

        body?.callText?.includes("render_native") || false,

      containsOutcomePreview:

        body?.callText?.includes("outcome_preview") || false,

      containsPayload:

        body?.callText?.includes("payload") || false,

    };

  });

const report = {

  schemaVersion:

    "phase736.outcome-preview-chained-json-body-isolation.v1",

  generatedAt:

    new Date().toISOString(),

  mode:

    "read-only",

  sourceFile,

  targetFile:

    source.targetFile,

  bodyCount:

    bodies.filter((item) => item.bodyFound).length,

  bodies,

  recommendation:

    "Compare chained res.status(200).json(...) bodies and patch only the authoritative preview success response object.",

  mutationBoundary:

    "No mutation performed. Chained response-object isolation only.",

};

fs.mkdirSync(

  "RENDERER_INSPECTION",

  { recursive: true }

);

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `outcome-preview-chained-json-body-isolation-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Outcome preview chained JSON body isolation written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      bodyCount: report.bodyCount,

      bodies: bodies.map((item) => ({

        candidateIndex: item.candidateIndex,

        score: item.score,

        bodyFound: item.bodyFound,

        containsOutcomePreview: item.containsOutcomePreview,

        containsPayload: item.containsPayload,

        bodyPreview:

          item.body?.callText?.slice(0, 500) || null,

      })),

    },

    null,

    2

  )

);

