
import { mkdirSync, writeFileSync } from "node:fs";

import { execFileSync } from "node:child_process";

const startedAt = new Date().toISOString();

const semanticInputPath = "sandbox/semantic-inputs/sample-semantic-intent.json";

const compiledPayloadPath = "scripts/render-native/generated/compiled-semantic-payload.json";

const renderedHtmlPath = "scripts/render-native/output/rendered-sandbox.html";

const payloadInspectionReportPath = "scripts/render-native/reports/payload-inspection-report.json";

const sandboxChainReportPath = "scripts/render-native/reports/sandbox-chain-report.json";

mkdirSync("scripts/render-native/generated", { recursive: true });

mkdirSync("scripts/render-native/output", { recursive: true });

mkdirSync("scripts/render-native/reports", { recursive: true });

const steps = [

  {

    name: "compile",

    command: "node",

    args: [

      "scripts/render-native/compile-semantic-intent.mjs",

      semanticInputPath,

      compiledPayloadPath

    ]

  },

  {

    name: "validate",

    command: "node",

    args: [

      "scripts/render-native/validate-payload.mjs",

      compiledPayloadPath

    ]

  },

  {

    name: "render",

    command: "node",

    args: [

      "scripts/render-native/render-payload.mjs",

      compiledPayloadPath,

      renderedHtmlPath

    ]

  },

  {

    name: "inspect",

    command: "node",

    args: [

      "scripts/render-native/inspect-payload.mjs",

      compiledPayloadPath,

      payloadInspectionReportPath

    ]

  }

];

const results = [];

for (const step of steps) {

  try {

    const output = execFileSync(step.command, step.args, { encoding: "utf8" });

    results.push({

      name: step.name,

      status: "pass",

      command: `${step.command} ${step.args.join(" ")}`,

      output: output.trim()

    });

  } catch (error) {

    results.push({

      name: step.name,

      status: "fail",

      command: `${step.command} ${step.args.join(" ")}`,

      output: error.stdout?.toString().trim() || "",

      error: error.stderr?.toString().trim() || error.message

    });

    break;

  }

}

const passed = results.every((step) => step.status === "pass");

const report = {

  schema_version: "phase736.render-native-sandbox-chain-report.v1",

  started_at: startedAt,

  completed_at: new Date().toISOString(),

  corridor: "sandbox-only",

  live_preview_mutated: false,

  status: passed ? "pass" : "fail",

  steps: results,

  artifacts: {

    semantic_input: semanticInputPath,

    compiled_payload: compiledPayloadPath,

    rendered_html: renderedHtmlPath,

    payload_inspection_report: payloadInspectionReportPath

  }

};

writeFileSync(sandboxChainReportPath, `${JSON.stringify(report, null, 2)}\n`);

console.log(`Sandbox chain ${passed ? "passed" : "failed"}.`);

console.log(sandboxChainReportPath);

if (!passed) process.exit(1);

