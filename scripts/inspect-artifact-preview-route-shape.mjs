
import fs from "fs";

import path from "path";

const targetFile = "server/routes/api-tasks-postgres.mjs";

const resolvedTarget = path.resolve(targetFile);

if (!fs.existsSync(resolvedTarget)) {

  console.error(`Missing target file: ${resolvedTarget}`);

  process.exit(1);

}

const text = fs.readFileSync(resolvedTarget, "utf8");

const tokens = [

  "artifact-preview",

  "artifactHtml",

  "preview",

  "visual-artifact",

  "semantic_artifact",

  "semantic_artifact_schema",

  "semantic_artifact_validated",

  "res.json",

  "router.get",

  "router.post",

  "task_id",

  "result",

  "metadata",

];

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

    contexts: indexes.slice(0, 10).map((item) => ({

      index: item,

      excerpt: text.slice(

        Math.max(0, item - 700),

        Math.min(text.length, item + token.length + 1200)

      ),

    })),

  };

});

const likelyPreviewRoutes = findings

  .filter((finding) =>

    ["artifact-preview", "res.json", "router.get"].includes(finding.token)

  )

  .flatMap((finding) =>

    finding.contexts.map((context) => ({

      token: finding.token,

      index: context.index,

      excerpt: context.excerpt,

    }))

  );

const report = {

  schemaVersion:

    "phase736.artifact-preview-route-shape-inspection.v1",

  generatedAt: new Date().toISOString(),

  mode: "read-only",

  targetFile,

  findings,

  likelyPreviewRoutes,

  recommendation:

    "Identify where preview payload JSON is assembled so structured render-native payloads can be introduced upstream of legacy HTML transport.",

  nextMutationBoundary:

    "Payload-shaping layer only. Do not mutate renderer transport or sanitizer logic.",

};

fs.mkdirSync("RENDERER_INSPECTION", {

  recursive: true,

});

const outputFile = path.join(

  "RENDERER_INSPECTION",

  `artifact-preview-route-shape-${new Date()

    .toISOString()

    .replace(/[:.]/g, "-")}.json`

);

fs.writeFileSync(

  outputFile,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(

  `Artifact preview route shape inspection written: ${outputFile}`

);

console.log(

  JSON.stringify(

    {

      targetFile,

      previewRouteContextCount: likelyPreviewRoutes.length,

      strongestSignals: findings

        .filter((finding) => finding.count > 0)

        .map((finding) => ({

          token: finding.token,

          count: finding.count,

        })),

    },

    null,

    2

  )

);

