
import fs from "fs";

import path from "path";

function readJson(filePath) {

  return JSON.parse(fs.readFileSync(filePath, "utf8"));

}

function zoneForPanel(panel) {

  if (panel.type === "hero") return "header";

  if (panel.type === "status-grid") return "primary";

  if (panel.type === "orchestration-map") return "primary";

  if (panel.type === "governance-boundary") return "governance";

  if (panel.type === "risk-zones") return "risk";

  if (panel.type === "executive-summary") return "summary";

  return "secondary";

}

function lifecycleForPanel(panel) {

  if (panel.type === "governance-boundary") {

    return {

      state: "persistent",

      visibility: "always-visible",

      collapseAllowed: false,

    };

  }

  if (panel.type === "risk-zones") {

    return {

      state: "attention",

      visibility: "visible-when-risk-present",

      collapseAllowed: true,

    };

  }

  if (panel.type === "hero" || panel.type === "status-grid") {

    return {

      state: "primary",

      visibility: "always-visible",

      collapseAllowed: false,

    };

  }

  return {

    state: "supporting",

    visibility: "visible",

    collapseAllowed: true,

  };

}

function behaviorForPanel(panel) {

  const renderer = panel.renderHints?.renderer || "panel";

  return {

    renderer,

    interaction:

      renderer === "topology-map"

        ? "inspectable-flow"

        : renderer === "status-card-grid"

          ? "status-scan"

          : renderer === "risk-card-grid"

            ? "risk-review"

            : "read-only-panel",

    emphasis: panel.renderHints?.emphasis || "secondary",

    animation: panel.renderHints?.animation || "none",

  };

}

function buildOrchestration(layout) {

  const composition = Array.isArray(layout.composition)

    ? layout.composition

    : [];

  const panels = composition

    .map((panel, index) => ({

      panelId: panel.regionId || `panel-${index + 1}`,

      type: panel.type,

      title: panel.title,

      zone: zoneForPanel(panel),

      priority: panel.visualPriority || 0,

      lifecycle: lifecycleForPanel(panel),

      behavior: behaviorForPanel(panel),

      placement: panel.gridPlacement || {},

      styling: panel.styling || {},

      payload: panel.payload || {},

    }))

    .sort((a, b) => b.priority - a.priority);

  const zones = panels.reduce((acc, panel) => {

    if (!acc[panel.zone]) acc[panel.zone] = [];

    acc[panel.zone].push(panel.panelId);

    return acc;

  }, {});

  return {

    schemaVersion: "phase736.render-native-panel-orchestration.v1",

    generatedAt: new Date().toISOString(),

    mode: "read-only",

    dashboardContract: {

      rendererTarget: "render-native-dashboard",

      fallbackRendererAllowed: false,

      markdownFallbackAllowed: false,

      semanticCardFallbackAllowed: false,

      executionAuthorized: false,

      mutationPermitted: false,

    },

    orchestration: {

      canvas: layout.canvas || {},

      zones,

      panelCount: panels.length,

      primaryPanels: panels

        .filter((panel) => panel.zone === "primary")

        .map((panel) => panel.panelId),

      persistentPanels: panels

        .filter((panel) => panel.lifecycle.state === "persistent")

        .map((panel) => panel.panelId),

      attentionPanels: panels

        .filter((panel) => panel.lifecycle.state === "attention")

        .map((panel) => panel.panelId),

    },

    renderSequence: panels.map((panel, index) => ({

      order: index + 1,

      panelId: panel.panelId,

      type: panel.type,

      renderer: panel.behavior.renderer,

      zone: panel.zone,

      priority: panel.priority,

    })),

    panels,

    governanceRules: layout.governanceRules || {

      executionAuthorized: false,

      mutationPermitted: false,

      humanApprovalRequired: true,

      reconciliationRequired: true,

      advisoryOnly: true,

    },

  };

}

function usage() {

  console.error(

    "Usage: node scripts/render-native-panel-orchestrator.mjs <layout-file.json> [output-file.json]"

  );

  process.exit(1);

}

const [layoutFile, outputFile] = process.argv.slice(2);

if (!layoutFile) {

  usage();

}

const resolvedLayoutFile = path.resolve(layoutFile);

const layout = readJson(resolvedLayoutFile);

const orchestration = buildOrchestration(layout);

orchestration.sourceLayout = {

  file: resolvedLayoutFile,

  schemaVersion: layout.schemaVersion || null,

  generatedAt: layout.generatedAt || null,

};

const output = `${JSON.stringify(orchestration, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Render-native panel orchestration written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

