
import fs from "fs";

const inputPath = process.argv[2];

if (!inputPath) {

  console.error("Missing semantic intent path.");

  process.exit(1);

}

const raw = fs.readFileSync(inputPath, "utf8");

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

const payload = {

  schema_version: "phase736.render-native-payload.v1",

  artifact_type: intent.artifact_type,

  scene: {

    id: `${intent.intent_id}-scene`,

    root: "root-node"

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

    }

  },

  style_tokens: {

    background: "surface-default",

    text: "text-primary",

    accent: "accent-signal",

    spacing: "comfortable"

  },

  nodes: [

    {

      id: "root-node",

      type: "container",

      style_token: "background",

      layout_token: "stack",

      content: {

        children: [

          "title-node",

          "body-node"

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

    }

  ],

  text: {

    title: intent.title,

    body: intent.body

  },

  validation: {

    deterministic: true,

    sandbox_only: true

  }

};

const outputPath =

  "scripts/render-native/generated/compiled-semantic-payload.json";

fs.writeFileSync(

  outputPath,

  JSON.stringify(payload, null, 2)

);

console.log("SEMANTIC COMPILE PASS");

console.log(`Compiled payload written to: ${outputPath}`);

