
import { spawnSync } from "child_process";

const semanticInputPath =

  process.argv[2] || "sandbox/semantic-inputs/sample-semantic-intent.json";

const compiledPayloadPath =

  "scripts/render-native/generated/compiled-semantic-payload.json";

const steps = [

  {

    name: "compile semantic intent",

    command: "node",

    args: [

      "scripts/render-native/compile-semantic-intent.mjs",

      semanticInputPath

    ]

  },

  {

    name: "validate compiled payload",

    command: "node",

    args: [

      "scripts/render-native/validate-payload.mjs",

      compiledPayloadPath

    ]

  },

  {

    name: "render compiled payload",

    command: "node",

    args: [

      "scripts/render-native/render-payload.mjs",

      compiledPayloadPath

    ]

  },

  {

    name: "inspect compiled payload",

    command: "node",

    args: [

      "scripts/render-native/inspect-payload.mjs",

      compiledPayloadPath

    ]

  }

];

for (const step of steps) {

  console.log(`RUNNING: ${step.name}`);

  const result = spawnSync(step.command, step.args, {

    stdio: "inherit"

  });

  if (result.status !== 0) {

    console.error(`SANDBOX CHAIN FAIL: ${step.name}`);

    process.exit(result.status || 1);

  }

}

console.log("SANDBOX CHAIN PASS");

