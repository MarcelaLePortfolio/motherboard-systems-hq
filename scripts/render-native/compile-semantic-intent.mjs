
import { readFileSync, writeFileSync, mkdirSync } from "node:fs";

const inputPath = process.argv[2];

const outputPath =

  process.argv[3] ||

  "scripts/render-native/generated/compiled-semantic-payload.json";

if (!inputPath) {

  console.error("Missing semantic intent path.");

  process.exit(1);

}

const raw = readFileSync(inputPath, "utf8");

const intent = JSON.parse(raw);

const requiredIntentFields = [

  "intent_id",

  "artifact_type",

  "title",

  "body",

  "layout_mode",

  "style_profile",

  "layout_profile"

];

for (const field of requiredIntentFields) {

  if (!(field in intent)) {

    console.error(`Missing semantic intent field: ${field}`);

    process.exit(1);

  }

}

const scenePattern = intent.scene_pattern || "status_card";

function createStatusCardNodes(intent) {

  return [

    {

      id: "root-node",

      type: "container",

      style_token: "background",

      layout_token: "stack",

      content: {

        children: [

          "title-node",

          "body-node",

          "status-node"

        ]

      }

    },

    {

      id: "title-node",

      type: "text",

      style_token: "text",

      layout_token: "card",

      content: {

        value: intent.title

      }

    },

    {

      id: "body-node",

      type: "text",

      style_token: "accent",

      layout_token: "card",

      content: {

        value: intent.body

      }

    },

    {

      id: "status-node",

      type: "text",

      style_token: "status-pass",

      layout_token: "badge",

      content: {

        value: intent.status_label || "PASS"

      }

    }

  ];

}

function createEvidenceCardNodes(intent) {

  return [

    {

      id: "root-node",

      type: "container",

      style_token: "background",

      layout_token: "stack",

      content: {

        children: [

          "title-node",

          "body-node",

          "evidence-node"

        ]

      }

    },

    {

      id: "title-node",

      type: "text",

      style_token: "text",

      layout_token: "card",

      content: {

        value: intent.title

      }

    },

    {

      id: "body-node",

      type: "text",

      style_token: "accent",

      layout_token: "card",

      content: {

        value: intent.body

      }

    },

    {

      id: "evidence-node",

      type: "text",

      style_token: "evidence",

      layout_token: "card",

      content: {

        value: intent.evidence_summary || "Evidence verified."

      }

    }

  ];

}

function createExecutionReadinessNodes(intent) {

  return [

    {

      id: "root-node",

      type: "container",

      style_token: "background",

      layout_token: "stack",

      content: {

        children: [

          "title-node",

          "body-node",

          "readiness-node",

          "blocking-node"

        ]

      }

    },

    {

      id: "title-node",

      type: "text",

      style_token: "text",

      layout_token: "card",

      content: {

        value: intent.title

      }

    },

    {

      id: "body-node",

      type: "text",

      style_token: "accent",

      layout_token: "card",

      content: {

        value: intent.body

      }

    },

    {

      id: "readiness-node",

      type: "text",

      style_token: "status-pass",

      layout_token: "badge",

      content: {

        value: intent.readiness_state || "READY"

      }

    },

    {

      id: "blocking-node",

      type: "text",

      style_token: "warning",

      layout_token: "card",

      content: {

        value: intent.blocking_conditions || "No blocking conditions."

      }

    }

  ];

}

function composeScene(intent) {

  switch (scenePattern) {

    case "evidence_card":

      return createEvidenceCardNodes(intent);

    case "execution_readiness_card":

      return createExecutionReadinessNodes(intent);

    case "status_card":

    default:

      return createStatusCardNodes(intent);

  }

}

const payload = {

  schema_version: "phase736.render-native-payload.v2",

  artifact_type: intent.artifact_type,

  scene: {

    id: `${intent.intent_id}-scene`,

    root: "root-node",

    pattern: scenePattern

  },

  layout: {

    mode: intent.layout_mode

  },

  layout_tokens: {

    stack: {

      direction: "vertical",

      gap: "medium",

      align: "start"

    },

    card: {

      padding: "large",

      radius: "medium"

    },

    badge: {

      padding: "small",

      radius: "pill"

    }

  },

  style_tokens: {

    background: "surface-default",

    text: "text-primary",

    accent: "accent-signal",

    evidence: "info-secondary",

    warning: "warning-signal",

    "status-pass": "success-signal",

    spacing: "comfortable"

  },

  nodes: composeScene(intent),

  text: {

    title: intent.title,

    body: intent.body

  },

  validation: {

    deterministic: true,

    sandbox_only: true,

    scene_composer: true

  }

};

mkdirSync("scripts/render-native/generated", { recursive: true });

writeFileSync(outputPath, JSON.stringify(payload, null, 2));

console.log("SEMANTIC COMPILE PASS");

console.log(`Compiled payload written to: ${outputPath}`);

