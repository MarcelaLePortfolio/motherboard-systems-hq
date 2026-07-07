
import express from "express";

import { randomUUID } from "node:crypto";

import { once } from "node:events";

import { createGovernanceLifecycleRouter } from "../server/routes/governance-lifecycle-route.js";

const PORT = Number(process.env.GOVERNANCE_LIFECYCLE_RUNTIME_PORT ?? 3100);

const BASE_URL = `http://127.0.0.1:${PORT}`;

const envelopeId = `env-governance-lifecycle-success-path-${randomUUID()}`;

const expectedFalseFlags = [

  "scheduler_authorized",

  "worker_claim_authorized",

  "orchestration_authorized",

  "routing_authorized",

  "execution_authorized",

  "new_authority_introduced",

];

function fakePersist({ envelope_id, transition_authorization, persisted_at }) {

  return {

    envelope_id,

    previous_lifecycle_state: transition_authorization.from,

    lifecycle_state: transition_authorization.to,

    assignment_state: "ASSIGNED",

    assigned_department: "engineering",

    assigned_actor: "cade",

    routing_history: "governance lifecycle success path runtime validation",

    persisted_at: persisted_at ?? "2026-06-26T11:59:00.000Z",

  };

}

function assertEqual(actual, expected, message) {

  if (actual !== expected) {

    throw new Error(`${message}. Expected ${JSON.stringify(expected)}, received ${JSON.stringify(actual)}`);

  }

}

async function main() {

  const app = express();

  app.use(express.json());

  app.get("/api/health", (_req, res) => res.json({ ok: true }));

  app.use(createGovernanceLifecycleRouter({ persist_lifecycle_transition: fakePersist }));

  const server = app.listen(PORT, "127.0.0.1");

  await once(server, "listening");

  try {

    const health = await fetch(`${BASE_URL}/api/health`);

    const healthBody = await health.json();

    assertEqual(health.ok, true, "Health HTTP status should be ok");

    assertEqual(healthBody.ok, true, "Health body should be ok:true");

    const response = await fetch(`${BASE_URL}/api/governance/lifecycle`, {

      method: "POST",

      headers: { "content-type": "application/json" },

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

    const result = await response.json();

    if (!response.ok) {

      console.error("Lifecycle response status:", response.status);

      console.error(JSON.stringify(result, null, 2));

    }

    assertEqual(response.ok, true, "Lifecycle HTTP status should be ok");

    assertEqual(result.ok, true, "Route result should be ok:true");

    assertEqual(result.route, "governance_lifecycle_route", "Route identity should match");

    assertEqual(result.endpoint_authorized, true, "Endpoint authority should be true");

    for (const flag of expectedFalseFlags) {

      assertEqual(result[flag], false, `${flag} should remain false`);

    }

    assertEqual(

      result.lifecycle?.lifecycle?.persistence?.lifecycle_state,

      "ASSIGNED",

      "Lifecycle persistence state should transition to ASSIGNED",

    );

    console.log("PASS: Governance lifecycle success path runtime validation completed.");

    console.log("PASS: ENVELOPE_CREATED transitioned to ASSIGNED.");

    console.log("PASS: Scheduler, worker, orchestration, routing, execution, and new authority remained false.");

  } finally {

    server.close();

    await once(server, "close");

  }

}

main().catch((error) => {

  console.error(`FAIL: ${error.message}`);

  process.exitCode = 1;

});

