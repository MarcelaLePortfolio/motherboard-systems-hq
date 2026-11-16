import test from "node:test";
import assert from "node:assert/strict";

import {
  digestDepartmentCredential,
} from "./department-service-identity";

import {
  admitProductionDepartmentIdentity,
} from "./production-department-identity-admission";

import {
  createIsolatedDepartmentCredentialProvider,
} from "./isolated-department-credential-provider";

const secret = "isolated-stage-3-synthetic-secret";

const trusted = {
  department_id: "engineering",
  credential_digest: digestDepartmentCredential(secret),
};

function admit(
  provider: ReturnType<
    typeof createIsolatedDepartmentCredentialProvider
  >,
  presented_credential: string = secret,
) {
  return admitProductionDepartmentIdentity({
    claimed_department_id: "engineering",
    presented_credential,
    credential_provider: provider,
  });
}

test("accepts matching synthetic credentials without granting authority", () => {
  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => [trusted],
  });

  const result = admit(provider);

  assert.equal(result.ok, true);
  assert.equal(result.mutation_authorized, false);
  assert.equal(result.execution_authorized, false);
  assert.equal(result.lifecycle_transition_authorized, false);
});

test("rejects forged synthetic credentials", () => {
  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => [trusted],
  });

  assert.equal(admit(provider, "forged-secret").ok, false);
});

test("rejects missing or unavailable credential sources", () => {
  assert.throws(
    () => createIsolatedDepartmentCredentialProvider(null as never),
    /source required/,
  );

  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => {
      throw new Error("Synthetic source unavailable");
    },
  });

  assert.equal(admit(provider).ok, false);
});

test("rejects malformed and duplicate department records", () => {
  const malformed = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => [{
      ...trusted,
      credential_digest: "invalid",
    }],
  });

  const duplicate = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => [trusted, trusted],
  });

  assert.equal(admit(malformed).ok, false);
  assert.equal(admit(duplicate).ok, false);
});

test("observes source revocation on subsequent admission", () => {
  let records = [trusted];

  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => records,
  });

  assert.equal(admit(provider).ok, true);

  records = [];

  assert.equal(admit(provider).ok, false);
});

test("does not accept caller-provided source overrides", () => {
  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => [],
  });

  const request = {
    claimed_department_id: "engineering",
    presented_credential: secret,
    credential_provider: provider,
    readCredentials: () => [trusted],
  };

  const result = admitProductionDepartmentIdentity(request);

  assert.equal(result.ok, false);
});

test("returns immutable credential snapshots", () => {
  const provider = createIsolatedDepartmentCredentialProvider({
    readCredentials: () => [trusted],
  });

  const snapshot = provider();

  assert.ok(snapshot);
  assert.equal(Object.isFrozen(snapshot), true);
  assert.equal(Object.isFrozen(snapshot[0]), true);
  assert.notEqual(snapshot[0], trusted);
});
