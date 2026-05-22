
import { mkdirSync, writeFileSync } from "node:fs";

import { execFileSync } from "node:child_process";

const startedAt = new Date().toISOString();

const reportDir = "scripts/render-native/reports";

mkdirSync(reportDir, { recursive: true });

const steps = [

  ["compile", "scripts/render-native/compile-semantic-intent.mjs"],

  ["validate", "scripts/render-native/validate-payload.mjs"],

  ["render", "scripts/render-native/render-payload.mjs"],

  ["inspect", "scripts/render-native/inspect-payload.mjs"],

];

const results = [];

for (const [name, script] of steps) {

  try {

    const output = execFileSync("node", [script], { encoding: "utf8" });

    results.push({ name, status: "pass", output: output.trim() });

  } catch (error) {

    results.push({

      name,

      status: "fail",

      output: error.stdout?.toString().trim() || "",

      error: error.stderr?.toString().trim() || error.message,

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

    semantic_input: "sandbox/semantic-inputs/sample-semantic-intent.json",

    compiled_payload: "scripts/render-native/generated/compiled-semantic-payload.json",

    rendered_html: "scripts/render-native/output/rendered-sandbox.html",

    payload_inspection_report: "scripts/render-native/reports/payload-inspection-report.json",

  },

};

writeFileSync(

  `${reportDir}/sandbox-chain-report.json`,

  `${JSON.stringify(report, null, 2)}\n`

);

console.log(`Sandbox chain ${passed ? "passed" : "failed"}.`);

console.log(`${reportDir}/sandbox-chain-report.json`);

if (!passed) process.exit(1);

