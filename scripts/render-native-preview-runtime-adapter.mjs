
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function componentForRenderer(renderer) {

  switch (renderer) {

    case "topology-map":

      return "TopologyMapPanel";

    case "status-card-grid":

      return "StatusGridPanel";

    case "risk-card-grid":

      return "RiskGridPanel";

    case "governance-boundary-panel":

      return "GovernanceBoundaryPanel";

    default:

      return "ExecutivePanel";

  }

}

function buildRuntimeAdapter(contract) {

  const dashboard = contract.dashboard || {};

  const panels = Array.isArray(dashboard.panels)

    ? dashboard.panels

    : [];

  const runtimePanels = panels.map((panel, index) => ({

    runtimeId: `runtime-panel-${index + 1}`,

    component: componentForRenderer(panel.renderer),

    renderer: panel.renderer,

    zone: panel.zone,

    priority: panel.priority,

    emphasis: panel.emphasis,

    animation: panel.animation,

    interaction: panel.interaction,

    placement: panel.placement,

    styling: panel.styling,

    lifecycle: panel.lifecycle,

    payload: panel.payload,

  }));

  return {

    schemaVersion: "phase736.render-native-preview-runtime.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    runtimeTarget: "motherboard-preview-runtime",

    renderMode: "render-native-dashboard",

    dashboardShell: {

      title: dashboard.title || "Executive Dashboard",

      subtitle: dashboard.subtitle || "",

      theme: dashboard.theme || {},

      zones: dashboard.zones || {},

    },

    runtimeComposition: {

      panelCount: runtimePanels.length,

      renderSequence:

        contract.dashboard?.renderSequence || [],

      panels: runtimePanels,

    },

    runtimeCapabilities: {

      multiPanelRendering: true,

      topologyMaps: true,

      governancePanels: true,

      statusGridRendering: true,

      riskGridRendering: true,

      animatedHierarchy: true,

      semanticCardFallbackAllowed: false,

      markdownFallbackAllowed: false,

    },

    governanceRules:

      contract.runtimeConstraints || {

        executionAuthorized: false,

        mutationPermitted: false,

        humanApprovalRequired: true,

        reconciliationRequired: true,

        advisoryOnly: true,

      },

    runtimeState: {

      sceneGraphConnected: true,

      layoutCompositionConnected: true,

      panelOrchestrationConnected: true,

      dashboardAdapterConnected: true,

      previewRuntimeConnected: true,

      rendererConsumptionReady: true,

    },

    sourceDashboardContract:

      contract.sourceOrchestration || null,

  };

}

function usage() {

  console.error(

    "Usage: node scripts/render-native-preview-runtime-adapter.mjs <dashboard-contract.json> [output-file.json]"

  );

  process.exit(1);

}

const [dashboardContractFile, outputFile] =

  process.argv.slice(2);

if (!dashboardContractFile) {

  usage();

}

const resolvedDashboardContractFile =

  path.resolve(dashboardContractFile);

const contract = readJson(

  resolvedDashboardContractFile

);

const runtimeAdapter =

  buildRuntimeAdapter(contract);

const output = `${JSON.stringify(runtimeAdapter, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), {

    recursive: true,

  });

  fs.writeFileSync(resolvedOutput, output);

  console.log(

    `Render-native preview runtime written: ${resolvedOutput}`

  );

} else {

  process.stdout.write(output);

}

