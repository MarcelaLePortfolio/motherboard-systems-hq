
import fs from "fs";

import path from "path";

function latestFile(dir, prefix, suffix = ".md") {

  const files = fs

    .readdirSync(dir)

    .filter((file) => file.startsWith(prefix) && file.endsWith(suffix))

    .map((file) => path.join(dir, file))

    .sort((a, b) => fs.statSync(b).mtimeMs - fs.statSync(a).mtimeMs);

  if (!files.length) {

    throw new Error(`No matching files for ${prefix}`);

  }

  return files[0];

}

const excerptFile = latestFile(

  "RENDERER_INSPECTION",

  "decode-token-excerpt-review-"

);

const text = fs.readFileSync(excerptFile, "utf8");

const functionPatterns = [

  /(?:const|let|var)\s+phase735DecodeVisualArtifactHtmlTransport\s*=\s*\([^)]*\)\s*=>/g,

  /(?:const|let|var)\s+phase735DecodeVisualArtifactHtmlTransport\s*=\s*function\s*\([^)]*\)/g,

  /phase735DecodeVisualArtifactHtmlTransport\s*\([^)]*\)/g,

  /phase735DecodeVisualArtifactHtmlTransport/g,

];

const findings = functionPatterns.map((pattern) => {

  const matches = [...text.matchAll(pattern)];

  return {

    pattern: String(pattern),

    count: matches.length,

    matches: matches.map((match) => ({

      index: match.index,

      value: match[0],

      excerpt: text.slice(

        Math.max(0, match.index - 600),

        Math.min(text.length, match.index + match[0].length + 900)

      ),

    })),

  };

});

const report = {

  schemaVersion: "phase736.decode-excerpt-shape-analysis.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceExcerpt: excerptFile,

  findings,

  recommendation:

    "Use detected function assignment/call shape to patch only a confirmed branch; do not attempt a guessed marker replacement.",

  failureDiscipline:

    "This preserves the third-attempt boundary by avoiding mutation until exact syntax is confirmed.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `decode-excerpt-shape-analysis-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Decode excerpt shape analysis written: ${outputFile}`);

console.log(JSON.stringify(findings.map(({ pattern, count }) => ({ pattern, count })), null, 2));

