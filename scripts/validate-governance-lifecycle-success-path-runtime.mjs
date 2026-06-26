
import { spawn } from "node:child_process";

import { randomUUID } from "node:crypto";

const PORT = process.env.GOVERNANCE_LIFECYCLE_RUNTIME_PORT ?? "3100";

const BASE_URL = process.env.GOVERNANCE_LIFECYCLE_RUNTIME_BASE_URL ?? `http://127.0.0.1:${PORT}`;

const HEALTH_URL = `${BASE_URL}/api/health`;

const LIFECYCLE_URL = `${BASE_URL}/api/governance/lifecycle`;

const runtimeEnv = {

  ...process.env,

  PORT,

};

const envelopeId = `env-governance-lifecycle-success-path-${randomUUID()}`;

const expectedFalseFlags = [

  "scheduler_authorized",

  "worker_claim_authorized",

  "orchestration_authorized",

  "routing_authorized",

  "execution_authorized",

  "new_authority_introduced",

];

let runtime;

function wait(ms) {

  return new Promise((resolve) => setTimeout(resolve, ms));

}

function bootRuntime() {

  runtime = spawn("node", ["--import", "tsx", "server.mjs"], {

    env: runtimeEnv,

    stdio: ["ignore", "pipe", "pipe"],

  });

  runtime.stdout.on("data", (chunk) => {

    process.stdout.write(`[runtime:stdout] ${chunk}`);

  });

  runtime.stderr.on("data", (chunk) => {

    process.stderr.write(`[runtime:stderr] ${chunk}`);

  });

}

async function waitForHealth(timeoutMs = 20000) {

  const startedAt = Date.now();

  while (Date.now() - startedAt < timeoutMs) {

    try {

      const response = await fetch(HEALTH_URL);

      const body = await response.json().catch(() => ({}));

      if (response.ok && body?.ok === true) {

        return body;

      }

    } catch {

      // Runtime may still be starting.

    }

    await wait(500);

  }

  throw new Error(`Timed out waiting for runtime health at ${HEALTH_URL}`);

}

async function postSuccessPath() {

  const response = await fetch(LIFECYCLE_URL, {

    method: "POST",

    headers: {

      "content-type": "application/json",

    },

    body: JSON.stringify({

      envelope_id: envelopeId,

      envelope: {

        lifecycle_state: "ENVELOPE_CREATED",

        required_capabilities: "engineering",

        operational_corridor: "governance lifecycle success path runtime validation",

      },

      available_departments: ["engineering"],

      available_actors: ["cade"],

      persisted_at: "2026-06-26T11:59:00.000Z",

    }),

  });

  const body = await response.json().catch(() => ({}));

  if (!response.ok) {

    throw new Error(

      `Expected success-path lifecycle request to succeed. HTTP ${response.status}: ${JSON.stringify(body, null, 2)}`,

    );

  }

  return body;

}

function assertSuccessPath(result) {

  if (result.ok !== true) {

    throw new Error(`Expected route result ok:true. Result: ${JSON.stringify(result, null, 2)}`);

  }

  if (result.route !== "governance_lifecycle_route") {

    throw new Error(`Expected governance lifecycle route. Result: ${JSON.stringify(result, null, 2)}`);

  }

  if (result.endpoint_authorized !== true) {

    throw new Error(`Expected endpoint_authorized true. Result: ${JSON.stringify(result, null, 2)}`);

  }

  for (const flag of expectedFalseFlags) {

    if (result[flag] !== false) {

      throw new Error(`Expected ${flag} false. Result: ${JSON.stringify(result, null, 2)}`);

    }

  }

  const lifecycleState = result.lifecycle?.lifecycle?.persistence?.lifecycle_state;

  if (lifecycleState !== "ASSIGNED") {

    throw new Error(

      `Expected lifecycle persistence state ASSIGNED, received ${JSON.stringify(lifecycleState)}. Result: ${JSON.stringify(result, null, 2)}`,

    );

  }

}

async function main() {

  console.log("Starting governance lifecycle success-path runtime validation.");

  console.log(`Runtime base URL: ${BASE_URL}`);

  console.log(`Disposable envelope id: ${envelopeId}`);

  bootRuntime();

  try {

    await waitForHealth();

    console.log("PASS: Runtime health returned ok:true.");

    const result = await postSuccessPath();

    assertSuccessPath(result);

    console.log("PASS: Lifecycle transitioned ENVELOPE_CREATED -> ASSIGNED.");

    console.log("PASS: Runtime authority flags preserved separation.");

  } finally {

    if (runtime && !runtime.killed) {

      runtime.kill("SIGTERM");

    }

  }

}

main().catch((error) => {

  console.error(`FAIL: ${error.message}`);

  if (runtime && !runtime.killed) {

    runtime.kill("SIGTERM");

  }

  process.exitCode = 1;

});

