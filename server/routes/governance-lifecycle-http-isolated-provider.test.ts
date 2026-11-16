import test from "node:test";
import assert from "node:assert/strict";
import express from "express";

import {
  createGovernanceLifecycleRouter,
} from "./governance-lifecycle-route";

import {
  digestDepartmentCredential,
} from "../ellis/department-service-identity";

import {
  createIsolatedDepartmentCredentialProvider,
} from "../ellis/isolated-department-credential-provider";

const secret = "isolated-stage-3-http-provider-secret";

const trusted = {
  department_id: "engineering",
  credential_digest: digestDepartmentCredential(secret),
};

const requestBody = {
  department_id: "engineering",
  envelope_id: "env-isolated-provider-http",
  envelope: {
    lifecycle_state: "ENVELOPE_CREATED",
    required_capabilities: "engineering",
    operational_corridor: "planning_only",
  },
  available_departments: ["engineering"],
  effect_intent: { kind: "no_effect" },
  department_handshake: {
    acknowledgement_status: "ACKNOWLEDGED",
    capability_status: "CAPABILITY_CONFIRMED",
    response_basis: "Caller-supplied acknowledgement",
  },
};

type CredentialSource = () => readonly (typeof trusted)[] | null;

async function request(
  credential: string | undefined,
  readCredentials: CredentialSource,
) {
  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials,
  });

  const app = express();
  app.use(express.json());

  app.use(createGovernanceLifecycleRouter({
    department_credential_provider: provider,
  }));

  const server = app.listen(0);

  try {
    const address = server.address();

    if (!address || typeof address === "string") {
      throw new Error("Unable to resolve isolated HTTP test port.");
    }

    const response = await fetch(
      `http://127.0.0.1:${address.port}/api/governance/lifecycle`,
      {
        method: "POST",
        headers: {
          "content-type": "application/json",
          ...(credential
            ? { "x-department-credential": credential }
            : {}),
        },
        body: JSON.stringify(requestBody),
      },
    );

    return {
      status: response.status,
      result: await response.json() as {
        ok: boolean;
        execution_authorized: boolean;
        new_authority_introduced?: boolean;
        findings: string[];
      },
    };
  } finally {
    await new Promise<void>((resolve, reject) => {
      server.close((error) => {
        if (error) reject(error);
        else resolve();
      });
    });
  }
}

test(
  "isolated HTTP provider authenticates synthetic identity without accepting caller acknowledgement",
  async () => {
    const response = await request(secret, () => [trusted]);

    assert.equal(response.status, 403);
    assert.equal(response.result.ok, false);
    assert.equal(response.result.execution_authorized, false);
    assert.equal(response.result.new_authority_introduced, false);

    assert.ok(
      response.result.findings.some((finding) =>
        finding.includes("not verified evidence"),
      ),
    );
  },
);

test(
  "isolated HTTP provider rejects forged credentials",
  async () => {
    const response = await request(
      "forged-isolated-http-secret",
      () => [trusted],
    );

    assert.equal(response.status, 403);
    assert.equal(response.result.ok, false);
    assert.equal(response.result.execution_authorized, false);

    assert.ok(
      response.result.findings.some((finding) =>
        finding.includes("unverified department identity"),
      ),
    );
  },
);

test(
  "isolated HTTP provider rejects missing credentials",
  async () => {
    const response = await request(undefined, () => [trusted]);

    assert.equal(response.status, 403);
    assert.equal(response.result.ok, false);
    assert.equal(response.result.execution_authorized, false);

    assert.ok(
      response.result.findings.some((finding) =>
        finding.includes("unverified department identity"),
      ),
    );
  },
);

test(
  "isolated HTTP provider rejects revoked synthetic credentials",
  async () => {
    let records: readonly (typeof trusted)[] = [trusted];

    const readCredentials = () => records;

    const accepted = await request(secret, readCredentials);

    assert.ok(
      accepted.result.findings.some((finding) =>
        finding.includes("not verified evidence"),
      ),
    );

    records = [];

    const revoked = await request(secret, readCredentials);

    assert.equal(revoked.status, 403);
    assert.equal(revoked.result.ok, false);
    assert.equal(revoked.result.execution_authorized, false);

    assert.ok(
      revoked.result.findings.some((finding) =>
        finding.includes("unverified department identity"),
      ),
    );
  },
);

test(
  "isolated HTTP provider fails closed when its source is unavailable",
  async () => {
    const response = await request(secret, () => {
      throw new Error("Synthetic credential source unavailable.");
    });

    assert.equal(response.status, 403);
    assert.equal(response.result.ok, false);
    assert.equal(response.result.execution_authorized, false);

    assert.ok(
      response.result.findings.some((finding) =>
        finding.includes("unverified department identity"),
      ),
    );
  },
);
