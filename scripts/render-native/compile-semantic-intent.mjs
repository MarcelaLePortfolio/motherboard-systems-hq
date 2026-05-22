
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

function baseLineage(nodeId) {

  return {

    generated_from: intent.intent_id,

    emitted_by: "compile-semantic-intent.mjs",

    snapshot_source: intent.snapshot_source || "sandbox-semantic-intent",

    lineage_scope: "semantic-only",

    node_id: nodeId

  };

}

function withGraph(node, meta = {}, relations = [], lineage = {}) {

  return {

    ...node,

    meta,

    relations,

    lineage: {

      ...baseLineage(node.id),

      ...lineage

    }

  };

}

function createStatusBadgeNode(id, value = "PASS", state = "pass") {

  return withGraph(

    {

      id,

      type: "status_badge",

      style_token: `status-${state}`,

      layout_token: "badge",

      content: {

        value,

        state

      }

    },

    {

      semantic_role: "state"

    },

    [],

    {

      validation_source: "sandbox-chain"

    }

  );

}

function createListNode(id, items = []) {

  return withGraph(

    {

      id,

      type: "list",

      style_token: "evidence",

      layout_token: "card",

      content: {

        items

      }

    },

    {

      semantic_role: "evidence"

    },

    [],

    {

      validation_source: "payload-inspection"

    }

  );

}

function createTextNode(id, value, styleToken = "text", layoutToken = "card") {

  return withGraph(

    {

      id,

      type: "text",

      style_token: styleToken,

      layout_token: layoutToken,

      content: {

        value

      }

    },

    {

      semantic_role: styleToken

    }

  );

}

function createRootNode(children) {

  return withGraph(

    {

      id: "root-node",

      type: "container",

      style_token: "background",

      layout_token: "stack",

      content: {

        children

      }

    },

    {

      semantic_role: "scene_root"

    },

    [],

    {

      snapshot_source: "compiled-scene-root"

    }

  );

}

function createStatusCardNodes(intent) {

  const titleNode = createTextNode(

    "title-node",

    intent.title,

    "text"

  );

  const bodyNode = createTextNode(

    "body-node",

    intent.body,

    "accent"

  );

  const statusNode = withGraph(

    createStatusBadgeNode(

      "status-node",

      intent.status_label || "PASS",

      intent.status_state || "pass"

    ),

    {

      semantic_role: "state"

    },

    [

      {

        type: "validates",

        target: "evidence-list-node"

      }

    ],

    {

      validation_source: "graph-relations-report"

    }

  );

  const evidenceNode = withGraph(

    createListNode(

      "evidence-list-node",

      intent.evidence_items || [

        "Sandbox chain passing",

        "Payload validation verified",

        "Renderer output deterministic"

      ]

    ),

    {

      semantic_role: "evidence_collection"

    },

    [

      {

        type: "validated_by",

        target: "status-node"

      }

    ],

    {

      validation_source: "graph-relations-report"

    }

  );

  return [

    createRootNode([

      "title-node",

      "body-node",

      "status-node",

      "evidence-list-node"

    ]),

    titleNode,

    bodyNode,

    statusNode,

    evidenceNode

  ];

}

function composeScene(intent) {

  switch (scenePattern) {

    case "status_card":

    default:

      return createStatusCardNodes(intent);

  }

}

const payload = {

  schema_version: "phase736.render-native-payload.v6",

  artifact_type: intent.artifact_type,

  lineage: {

    generated_from: intent.intent_id,

    emitted_by: "compile-semantic-intent.mjs",

    snapshot_source: intent.snapshot_source || "sandbox-semantic-intent",

    lineage_scope: "semantic-only"

  },

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

    status_badge_nodes: true,

    semantic_relations: true,

    graph_structure: true,

    semantic_lineage: true

  }

};

mkdirSync("scripts/render-native/generated", { recursive: true });

writeFileSync(outputPath, JSON.stringify(payload, null, 2));

console.log("SEMANTIC COMPILE PASS");

console.log(`Compiled payload written to: ${outputPath}`);

