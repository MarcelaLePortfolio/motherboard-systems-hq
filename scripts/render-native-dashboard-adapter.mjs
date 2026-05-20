
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function normalizePanel(panel) {

  return {

    id: panel.panelId,

    type: panel.type,

    zone: panel.zone,

    priority: panel.priority,

    renderer: panel.behavior?.renderer || "panel",

    emphasis: panel.behavior?.emphasis || "secondary",

    animation: panel.behavior?.animation || "none",

    interaction: panel.behavior?.interaction || "read-only-panel",

    placement: panel.placement || {},

    styling: {

      accent: panel.styling?.accent || "teal",

      glassmorphism: panel.styling?.glassmorphism ?? true,

      glow: panel.styling?.glow ?? true,

      borderIntensity: panel.styling?.borderIntensity || "medium",

    },

    lifecycle: panel.lifecycle || {},

    payload: panel.payload || {},

  };

}

function buildDashboardContract(orchestration) {

  const panels = Array.isArray(orchestration.panels)

    ? orchestration.panels

    : [];

  const normalizedPanels = panels.map(normalizePanel);

  return {

    schemaVersion: "phase736.render-native-dashboard-adapter.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    rendererTarget: "motherboard-render-native-dashboard",

    renderMode: "render-native",

    fallbackPolicy: {

      semanticCardFallbackAllowed: false,

      markdownFallbackAllowed: false,

      plainTextFallbackAllowed: false,

    },

    dashboard: {

      title: "Execution Bridge Readiness Command Center",

      subtitle:

        "Render-native executive operational dashboard contract",

      theme: {

        background: orchestration?.orchestration?.canvas?.background || "navy-glass",

        hierarchy: orchestration?.orchestration?.canvas?.hierarchy || "command-center",

        density: orchestration?.orchestration?.canvas?.density || "executive",

        accents:

          orchestration?.orchestration?.canvas?.accents || [

            "teal",

            "violet",

            "amber",

            "coral",

            "emerald",

          ],

      },

      zones: orchestration?.orchestration?.zones || {},

      renderSequence: orchestration?.renderSequence || [],

      panels: normalizedPanels,

    },

    rendererContracts: {

      topologyMap: {

        supported: true,

        renderer: "topology-map",

        interactive: true,

      },

      statusGrid: {

        supported: true,

        renderer: "status-card-grid",

        interactive: false,

      },

      riskGrid: {

        supported: true,

        renderer: "risk-card-grid",

        interactive: true,

      },

      governancePanel: {

        supported: true,

        renderer: "governance-boundary-panel",

        persistent: true,

      },

    },

    runtimeConstraints: {

      executionAuthorized: false,

      mutationPermitted: false,

      humanApprovalRequired: true,

      reconciliationRequired: true,

      advisoryOnly: true,

    },

    adapterState: {

      rendererReady: true,

      dashboardContractReady: true,

      sceneGraphConnected: true,

      layoutCompositionConnected: true,

      panelOrchestrationConnected: true,

      awaitingRendererConsumptionLayer: true,

    },

    sourceOrchestration: orchestration.sourceLayout || null,

  };

}

function usage() {

  console.error(

    "Usage: node scripts/render-native-dashboard-adapter.mjs <orchestration-file.json> [output-file.json]"

  );

  process.exit(1);

}

const [orchestrationFile, outputFile] = process.argv.slice(2);

if (!orchestrationFile) {

  usage();

}

const resolvedOrchestrationFile = path.resolve(orchestrationFile);

const orchestration = readJson(resolvedOrchestrationFile);

const dashboardContract = buildDashboardContract(orchestration);

const output = `${JSON.stringify(dashboardContract, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), {

    recursive: true,

  });

  fs.writeFileSync(resolvedOutput, output);

  console.log(

    `Render-native dashboard adapter written: ${resolvedOutput}`

  );

} else {

  process.stdout.write(output);

}

