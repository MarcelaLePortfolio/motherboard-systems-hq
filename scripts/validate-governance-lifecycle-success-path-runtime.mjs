
#!/usr/bin/env node

import { spawn } from "node:child_process";

import { randomUUID } from "node:crypto";

const BASE_URL =

  process.env.GOVERNANCE_LIFECYCLE_RUNTIME_BASE_URL ?? "http://127.0.0.1:3000";

const HEALTH_URL = `${BASE_URL}/api/health`;

const LIFECYCLE_URL = `${BASE_URL}/api/governance/lifecycle`;

const BOOT_COMMAND =

  process.env.GOVERNANCE_LIFECYCLE_RUNTIME_BOOT_COMMAND ??

  "pnpm exec tsx server/index.ts";

const disposableEnvelopeId = `success-path-${randomUUID()}`;

const expectedFalseAuthorityFlags = [

  "scheduler_authorized",

  "worker_claim_authorized",

  "orchestration_authorized",

  "routing_authorized",

  "execution_authorized",

  "new_authority_introduced",

];

let serverProcess;

function fail(message, details) {

  console.error(`FAIL: ${message}`);

  if (details !== undefined) {

    console.error(JSON.stringify(details, null, 2));

  }

  process.exitCode = 1;

}

function splitCommand(commandString) {

  return commandString.split(" ").filter(Boolean);

}

function bootRuntime() {

  const [command, ...args] = splitCommand(BOOT_COMMAND);

  serverProcess = spawn(command, args, {

    stdio: ["ignore", "pipe", "pipe"],

    env: {

      ...process.env,

      NODE_ENV: process.env.NODE_ENV ?? "test",

      GOVERNANCE_LIFECYCLE_VALIDATION_MODE: "success-path",

    },

  });

  serverProcess.stdout.on("data", (chunk) => {

    process.stdout.write(`[runtime] ${chunk}`);

  });

  serverProcess.stderr.on("data", (chunk) => {

    process.stderr.write(`[runtime] ${chunk}`);

  });

}

async function waitForHealth(timeoutMs = 15000) {

  const startedAt = Date.now();

  while (Date.now() - startedAt < timeoutMs) {

    try {

      const response = await fetch(HEALTH_URL);

      const body = await response.json().catch(() => ({}));

      if (response.ok && body?.ok === true) {

        return body;

      }

    } catch {

      // Runtime may still be booting.

    }

    await new Promise((resolve) => setTimeout(resolve, 500));

  }

  throw new Error(`Timed out waiting for mounted runtime health at ${HEALTH_URL}`);

}

async function postLifecycleSuccessPath() {

  const payload = {

    validation_mode: "success_path_runtime",

    disposable: true,

    envelope: {

      envelope_id: disposableEnvelopeId,

      lifecycle_state: "ENVELOPE_CREATED",

      required_capabilities: ["assignment_readiness"],

      authority_flags: {

        endpoint_authorized: true,

        scheduler_authorized: false,

        worker_claim_authorized: false,

        orchestration_authorized: false,

        routing_authorized: false,

        execution_authorized: false,

        new_authority_introduced: false,

      },

    },

    requested_transition: {

      from: "ENVELOPE_CREATED",

      to: "ASSIGNED",

    },

  };

  const response = await fetch(LIFECYCLE_URL, {

    method: "POST",

    headers: {

      "content-type": "application/json",

    },

    body: JSON.stringify(payload),

  });

  const body = await response.json().catch(() => ({}));

  if (!response.ok) {

    throw new Error(

      `Expected success-path lifecycle request to succeed. HTTP ${response.status}: ${JSON.stringify(

        body,

        null,

        2,

      )}`,

    );

  }

  return body;

}

function readLifecycleState(body) {

  return (

    body?.lifecycle_state ??

    body?.state ??

    body?.result?.lifecycle_state ??

    body?.result?.state ??

    body?.transition?.to ??

    body?.result?.transition?.to

  );

}

function readAuthorityFlags(body) {

  return (

    body?.authority_flags ??

    body?.result?.authority_flags ??

    body?.authorization?.authority_flags ??

    body?.result?.authorization?.authority_flags ??

    {}

  );

}

function assertSuccessPath(body) {

  const resolvedState = readLifecycleState(body);

  if (resolvedState !== "ASSIGNED") {

    throw new Error(

      `Expected lifecycle state ASSIGNED, received ${JSON.stringify(

        resolvedState,

      )}. Full response: ${JSON.stringify(body, null, 2)}`,

    );

  }

  const flags = readAuthorityFlags(body);

  if (flags.endpoint_authorized !== true) {

    throw new Error(

      `Expected endpoint_authorized true at route boundary. Full response: ${JSON.stringify(

        body,

        null,

        2,

      )}`,

    );

  }

  for (const flag of expectedFalseAuthorityFlags) {

    if (flags[flag] !== false) {

      throw new Error(

        `Expected ${flag} to remain false. Full response: ${JSON.stringify(

          body,

          null,

          2,

        )}`,

      );

    }

  }

}

async function main() {

  console.log("Starting governance lifecycle success-path runtime validation.");

  console.log(`Disposable envelope id: ${disposableEnvelopeId}`);

  bootRuntime();

  try {

    await waitForHealth();

    console.log("PASS: Runtime health check returned ok:true.");

    const responseBody = await postLifecycleSuccessPath();

    assertSuccessPath(responseBody);

    console.log("PASS: Lifecycle transitioned ENVELOPE_CREATED -> ASSIGNED.");

    console.log("PASS: Authority flags preserved runtime separation.");

  } finally {

    if (serverProcess && !serverProcess.killed) {

      serverProcess.kill("SIGTERM");

    }

  }

}

main().catch((error) => {

  fail(error.message);

});

