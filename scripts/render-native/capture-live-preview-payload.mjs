
import { writeFileSync, mkdirSync } from "node:fs";

const baseUrl =

  process.env.MOTHERBOARD_BASE_URL ||

  "http://localhost:3000";

const taskId =

  process.argv[2] ||

  process.env.MOTHERBOARD_PREVIEW_TASK_ID;

if (!taskId) {

  console.error("Missing task id.");

  console.error("Usage:");

  console.error("node scripts/render-native/capture-live-preview-payload.mjs <task_id>");

  process.exit(1);

}

const timestamp = new Date()

  .toISOString()

  .replaceAll(":", "-")

  .replaceAll(".", "-");

const outputDir = "scripts/render-native/runtime-captures";

const outputPath = `${outputDir}/live-preview-payload-${taskId}-${timestamp}.json`;

const url = `${baseUrl}/api/tasks/${encodeURIComponent(taskId)}/artifact-preview`;

mkdirSync(outputDir, { recursive: true });

const response = await fetch(url, {

  method: "GET",

  headers: {

    "accept": "application/json"

  }

});

const text = await response.text();

let parsed = null;

try {

  parsed = JSON.parse(text);

} catch {

  parsed = {

    parse_error: true,

    raw_text: text

  };

}

const capture = {

  schema_version: "phase736.live-preview-payload-capture.v1",

  corridor: "read-only-runtime-evidence",

  captured_at: new Date().toISOString(),

  request: {

    base_url: baseUrl,

    task_id: taskId,

    url,

    method: "GET"

  },

  response: {

    ok: response.ok,

    status: response.status,

    status_text: response.statusText,

    headers: Object.fromEntries(response.headers.entries())

  },

  payload: parsed,

  constraints: {

    live_preview_mutated: false,

    renderer_intercepted: false,

    browser_injected: false,

    runtime_patched: false

  }

};

writeFileSync(outputPath, `${JSON.stringify(capture, null, 2)}\n`);

console.log("LIVE PREVIEW PAYLOAD CAPTURE COMPLETE");

console.log(outputPath);

if (!response.ok) {

  process.exit(1);

}

