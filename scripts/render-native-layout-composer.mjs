
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function columnSpanForRegion(type) {

  switch (type) {

    case "hero":

      return 12;

    case "status-grid":

      return 12;

    case "orchestration-map":

      return 8;

    case "governance-boundary":

      return 4;

    case "risk-zones":

      return 6;

    case "executive-summary":

      return 6;

    default:

      return 12;

  }

}

function visualPriority(type) {

  switch (type) {

    case "hero":

      return 100;

    case "status-grid":

      return 90;

    case "orchestration-map":

      return 80;

    case "governance-boundary":

      return 70;

    case "risk-zones":

      return 60;

    case "executive-summary":

      return 50;

    default:

      return 10;

  }

}

function buildLayout(scene) {

  const regions = Array.isArray(scene.regions) ? scene.regions : [];

  return {

    schemaVersion: "phase736.render-native-layout.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    sceneType: scene.sceneType || "executiveDashboard",

    canvas: {

      layout: "executive-command-center",

      columns: 12,

      gap: 24,

      density: scene?.theme?.density || "executive",

      hierarchy: scene?.theme?.hierarchy || "command-center",

      background: scene?.theme?.background || "navy-glass",

      accents: scene?.theme?.accents || [],

    },

    composition: regions.map((region, index) => ({

      regionId: `region-${index + 1}`,

      type: region.type,

      title: region.title || null,

      visualPriority: visualPriority(region.type),

      gridPlacement: {

        columnStart:

          region.type === "governance-boundary"

            ? 9

            : 1,

        columnSpan: columnSpanForRegion(region.type),

      },

      styling: {

        glassmorphism: true,

        glow: true,

        borderIntensity:

          region.type === "governance-boundary"

            ? "high"

            : "medium",

        accent:

          region.type === "governance-boundary"

            ? "amber"

            : region.type === "risk-zones"

              ? "coral"

              : region.type === "status-grid"

                ? "emerald"

                : "teal",

      },

      renderHints: {

        renderer:

          region.type === "orchestration-map"

            ? "topology-map"

            : region.type === "status-grid"

              ? "status-card-grid"

              : region.type === "risk-zones"

                ? "risk-card-grid"

                : "panel",

        animation:

          region.type === "hero"

            ? "subtle-pulse"

            : "none",

        emphasis:

          visualPriority(region.type) >= 80

            ? "primary"

            : "secondary",

      },

      payload: region,

    })),

    governanceRules: scene.governanceRules || {

      executionAuthorized: false,

      mutationPermitted: false,

      humanApprovalRequired: true,

      reconciliationRequired: true,

      advisoryOnly: true,

    },

    sourceScene: scene.sourcePreviewRun || null,

  };

}

function usage() {

  console.error(

    "Usage: node scripts/render-native-layout-composer.mjs <scene-file.json> [output-file.json]"

  );

  process.exit(1);

}

const [sceneFile, outputFile] = process.argv.slice(2);

if (!sceneFile) {

  usage();

}

const resolvedSceneFile = path.resolve(sceneFile);

const scene = readJson(resolvedSceneFile);

const layout = buildLayout(scene);

const output = `${JSON.stringify(layout, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), {

    recursive: true,

  });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Render-native layout written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

