
import fs from "fs";

import path from "path";

const sceneSchema = {

  schemaVersion: "phase736.render-native-scene.v1",

  mode: "read-only",

  description:

    "Structured visual scene contract for render-native executive artifact composition.",

  sceneTypes: {

    executiveDashboard: {

      requiredFields: [

        "title",

        "subtitle",

        "statusBadge",

        "theme",

        "regions",

      ],

      supportedRegions: [

        "hero",

        "status-grid",

        "orchestration-map",

        "governance-boundary",

        "risk-zones",

        "executive-summary",

        "readiness-gate",

        "reconciliation",

      ],

    },

  },

  visualPrimitives: {

    hero: {

      fields: ["title", "subtitle", "badges"],

    },

    statusCard: {

      fields: ["label", "status", "tone", "detail"],

      tones: ["ready", "blocked", "warning", "info", "critical"],

    },

    orchestrationNode: {

      fields: ["label", "stage", "status", "tone"],

    },

    governanceBlock: {

      fields: ["title", "requirements", "tone"],

    },

    riskCard: {

      fields: ["label", "severity", "description", "mitigation"],

      severities: ["low", "medium", "high", "critical"],

    },

    summaryPanel: {

      fields: ["title", "body", "highlights"],

    },

  },

  themeTokens: {

    backgrounds: ["navy-glass", "graphite", "midnight-gradient"],

    accents: ["teal", "violet", "amber", "coral", "emerald"],

    density: ["compact", "balanced", "executive"],

    hierarchy: ["card-grid", "command-center", "briefing-board"],

  },

  governanceRules: {

    executionAuthorized: false,

    mutationPermitted: false,

    humanApprovalRequired: true,

    reconciliationRequired: true,

    advisoryOnly: true,

  },

};

function usage() {

  console.error("Usage: node scripts/render-native-scene-schema.mjs [output-file.json]");

  process.exit(1);

}

const [outputFile] = process.argv.slice(2);

const output = `${JSON.stringify(sceneSchema, null, 2)}\n`;

if (outputFile) {

  const resolvedOutput = path.resolve(outputFile);

  fs.mkdirSync(path.dirname(resolvedOutput), { recursive: true });

  fs.writeFileSync(resolvedOutput, output);

  console.log(`Render-native scene schema written: ${resolvedOutput}`);

} else {

  process.stdout.write(output);

}

