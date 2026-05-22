
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

function createStatusBadgeNode(id, value = "PASS", state = "pass") {

  return {

    id,

    type: "status_badge",

    style_token: `status-${state}`,

    layout_token: "badge",

    content: {

      value,

      state

    }

  };

}

function createListNode(id, items = []) {

  return {

    id,

    type: "list",

    style_token: "evidence",

    layout_token: "card",

    content: {

      items

    }

  };

}

function createTextNode(id, value, styleToken = "text", layoutToken = "card") {

  return {

    id,

    type: "text",

    style_token: styleToken,

    layout_token: layoutToken,

    content: {

      value

    }

  };

}

function createRootNode(children) {

  return {

    id: "root-node",

    type: "container",

    style_token: "background",

    layout_token: "stack",

    content: {

      children

    }

  };

}

function createStatusCardNodes(intent) {

  return [

    createRootNode([

      "title-node",

      "body-node",

      "status-node",

      "evidence-list-node"

    ]),

    createTextNode("title-node", intent.title, "text"),

    createTextNode("body-node", intent.body, "accent"),

    createStatusBadgeNode(

      "status-node",

      intent.status_label || "PASS",

      intent.status_state || "pass"

    ),

    createListNode(

      "evidence-list-node",

      intent.evidence_items || [

        "Sandbox chain passing",

        "Payload validation verified",

        "Renderer output deterministic"

      ]

    )

  ];

}

function createEvidenceCardNodes(intent) {

  return [

    createRootNode([

      "title-node",

      "body-node",

      "status-node",

      "evidence-node",

      "evidence-list-node"

    ]),

    createTextNode("title-node", intent.title, "text"),

    createTextNode("body-node", intent.body, "accent"),

    createStatusBadgeNode(

      "status-node",

      intent.status_label || "VERIFIED",

      intent.status_state || "pass"

    ),

    createTextNode(

      "evidence-node",

      intent.evidence_summary || "Evidence verified.",

      "evidence"

    ),

    createListNode(

      "evidence-list-node",

      intent.evidence_items || [

        "Payload contract locked",

        "HTML structure verified",

        "Scene composition stable"

      ]

    )

  ];

}

function createExecutionReadinessNodes(intent) {

  return [

    createRootNode([

      "title-node",

      "body-node",

      "status-node",

      "blocking-node",

      "readiness-list-node"

    ]),

    createTextNode("title-node", intent.title, "text"),

    createTextNode("body-node", intent.body, "accent"),

    createStatusBadgeNode(

      "status-node",

      intent.readiness_state || "READY",

      intent.status_state || "pass"

    ),

    createTextNode(

      "blocking-node",

      intent.blocking_conditions || "No blocking conditions.",

      "warning"

    ),

    createListNode(

      "readiness-list-node",

      intent.readiness_items || [

        "Sandbox renderer stable",

        "Payload schema locked",

        "External DR backup completed"

      ]

    )

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

  schema_version: "phase736.render-native-payload.v4",

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

    "status-warning": "warning-signal",

    "status-fail": "danger-signal",

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

    scene_composer: true,

    list_nodes: true,

    status_badge_nodes: true

  }

};

mkdirSync("scripts/render-native/generated", { recursive: true });

writeFileSync(outputPath, JSON.stringify(payload, null, 2));

console.log("SEMANTIC COMPILE PASS");

console.log(`Compiled payload written to: ${outputPath}`);

