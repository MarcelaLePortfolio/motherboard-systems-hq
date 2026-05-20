
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

const sourceFile = latestFile(

  "RENDERER_INSPECTION",

  "preview-callsite-62769-"

);

const source = JSON.parse(fs.readFileSync(sourceFile, "utf8"));

const excerpt = source.excerpt || "";

const markers = [

  "phase735DecodeVisualArtifactHtmlTransport(",

  "phase723SanitizeVisualArtifactHtml(",

  "innerHTML",

  "artifactHtml",

  "renderedHtml",

  "modal",

  "preview",

  "return",

];

const markerFindings = markers.map((marker) => {

  const indexes = [];

  let index = 0;

  while ((index = excerpt.indexOf(marker, index)) !== -1) {

    indexes.push(index);

    index += marker.length;

  }

  return {

    marker,

    count: indexes.length,

    indexes,

    contexts: indexes.map((item) => ({

      index: item,

      excerpt: excerpt.slice(

        Math.max(0, item - 350),

        Math.min(excerpt.length, item + marker.length + 550)

      ),

    })),

  };

});

const report = {

  schemaVersion: "phase736.preview-callsite-62769-shape-analysis.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  sourceFile,

  targetFile: source.targetFile,

  targetIndex: source.targetIndex,

  markerFindings,

  recommendation:

    "Use this shape analysis to patch only the confirmed preview call-site branch. If the next route activation fails, revert route activation scripts before further renderer work.",

};

fs.mkdirSync("RENDERER_INSPECTION", { recursive: true });

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `preview-callsite-62769-shape-${new Date().toISOString().replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(outputFile, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Preview call-site shape analysis written: ${outputFile}`);

console.log(JSON.stringify(markerFindings.map(({ marker, count, indexes }) => ({ marker, count, indexes })), null, 2));

