
import fs from "fs";

import path from "path";

const targetFiles = [

  "server/routes/api-tasks-postgres.mjs",

  "worker/semantic/classifyArtifact.js",

  "worker/semantic/validateSemanticArtifact.js",

  "server/worker/task_execution_interpreter.mjs",

  "public/js/phase530_visible_panels_bridge.js",

];

const tokens = [

  "artifactHtml",

  "artifact_html",

  "preview",

  "artifact-preview",

  "visual-artifact",

  "semantic_artifact",

  "semantic_artifact_schema",

  "semantic_artifact_validated",

  "renderNative",

  "render-native",

  "metadata",

  "result",

  "task",

];

function inspectFile(filePath) {

  const resolved = path.resolve(filePath);

  if (!fs.existsSync(resolved)) {

    return {

      filePath,

      exists: false,

      findings: [],

    };

  }

  const text = fs.readFileSync(resolved, "utf8");

  const findings = tokens.map((token) => {

    const indexes = [];

    let index = 0;

    while ((index = text.indexOf(token, index)) !== -1) {

      indexes.push(index);

      index += token.length;

    }

    return {

      token,

      count: indexes.length,

      indexes,

      contexts: indexes.slice(0, 8).map((item) => ({

        index: item,

        excerpt: text.slice(

          Math.max(0, item - 500),

          Math.min(text.length, item + token.length + 800)

        ),

      })),

    };

  });

  return {

    filePath,

    exists: true,

    findings,

  };

}

const inspections = targetFiles.map(inspectFile);

const report = {

  schemaVersion:

    "phase736.upstream-render-native-payload-target-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  purpose:

    "Identify upstream structured payload routing targets before touching legacy renderer transport.",

  targetFiles,

  inspections,

  recommendation:

    "Prefer adding structured render-native payload metadata upstream of Preview HTML transport instead of mutating sanitizer/decode renderer internals.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `upstream-render-native-payload-targets-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Upstream render-native payload target inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    inspections.map((inspection) => ({

      filePath: inspection.filePath,

      exists: inspection.exists,

      strongestSignals: inspection.findings

        .filter((finding) => finding.count > 0)

        .map((finding) => ({

          token: finding.token,

          count: finding.count,

        }))

        .slice(0, 8),

    })),

    null,

    2

  )

);

