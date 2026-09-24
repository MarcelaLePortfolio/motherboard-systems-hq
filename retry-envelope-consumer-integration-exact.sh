#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="01ecd4acd"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

CONSUMER="server/envelope/production-envelope-consumer.ts"
TEST="server/envelope/production-envelope-consumer.test.ts"

cat > "$CONSUMER" << 'TS'
import {
  createGovernanceEnvelope,
  type CreatedGovernanceEnvelope,
  type CreateGovernanceEnvelopeInput,
} from "../../db/governance-runtime.js";

import {
  createGovernanceEnvelopeCreationReadLoader,
  type GovernanceEnvelopeCreationReadLoader,
} from "../../db/governance-envelope-creation-read-repository.js";

import {
  invokeProductionEnvelopeEntryPoint,
  type GovernanceEnvelopePersistenceFunction,
  type ProductionEnvelopeEntryPointInput,
  type ProductionEnvelopeEntryPointResult,
} from "./production-envelope-entry-point.js";

import {
  resolveGovernanceEnvelopeSemantics,
} from "./governance-envelope-semantics.js";

export type ProductionEnvelopeConsumerInput = Omit<
  ProductionEnvelopeEntryPointInput,
  "create_governance_envelope"
> & {
  create_governance_envelope?: GovernanceEnvelopePersistenceFunction;
};

export type ProductionEnvelopeConsumerOptions = {
  load_exact_governance_envelope_creation_read_chain?: GovernanceEnvelopeCreationReadLoader;
};

export type ProductionEnvelopeConsumerResult =
  ProductionEnvelopeEntryPointResult;

function createDefaultEnvelopePersistence(): GovernanceEnvelopePersistenceFunction {
  return (
    input: CreateGovernanceEnvelopeInput,
  ): CreatedGovernanceEnvelope => createGovernanceEnvelope(input);
}

function failedClosed(findings: string[]): ProductionEnvelopeConsumerResult {
  return {
    ok: false,
    entry_point: "production_envelope_entry_point",
    endpoint_authorized: false,
    scheduler_authorized: false,
    worker_claim_authorized: false,
    orchestration_authorized: false,
    routing_authorized: false,
    assignment_authorized: false,
    lifecycle_transition_authorized: false,
    execution_authorized: false,
    downstream_governance_authorized: false,
    new_authority_introduced: false,
    findings,
  };
}

export function consumeProductionEnvelopeEntryPoint(
  input: ProductionEnvelopeConsumerInput,
  options: ProductionEnvelopeConsumerOptions = {},
): ProductionEnvelopeConsumerResult {
  try {
    const loadExactEnvelopeCreationReadChain =
      options.load_exact_governance_envelope_creation_read_chain ??
      createGovernanceEnvelopeCreationReadLoader();

    const readChain = loadExactEnvelopeCreationReadChain({
      validation_result_id: input.validation_result_id,
      envelope_gate_id: input.envelope_gate_id,
      delegation_id: input.delegation_id,
      package_id: input.package_id,
      package_version: input.package_version,
    });

    if (
      readChain.validation_result.validation_status.trim() !==
      "VALIDATION_PASSED"
    ) {
      throw new Error(
        "Production Envelope Consumer requires exact VALIDATION_PASSED status.",
      );
    }

    if (readChain.envelope_gate.gate_status.trim() !== "OPEN") {
      throw new Error(
        "Production Envelope Consumer requires exact OPEN Envelope Gate status.",
      );
    }

    const semantics = resolveGovernanceEnvelopeSemantics(
      readChain.validation_result,
    );

    return invokeProductionEnvelopeEntryPoint({
      envelope_id: input.envelope_id,
      package_id: input.package_id,
      package_version: input.package_version,
      delegation_id: input.delegation_id,
      validation_result_id: input.validation_result_id,
      envelope_gate_id: input.envelope_gate_id,
      validation_status: readChain.validation_result.validation_status.trim(),
      required_capabilities: semantics.required_capabilities,
      operational_corridor: semantics.operational_corridor,
      lifecycle_state: input.lifecycle_state,
      create_governance_envelope:
        input.create_governance_envelope ??
        createDefaultEnvelopePersistence(),
    });
  } catch (error) {
    return failedClosed([
      `Production Envelope eligibility failed closed: ${
        error instanceof Error ? error.message : String(error)
      }`,
    ]);
  }
}
TS

cat > "$TEST" << 'TS'
import test from "node:test";
import assert from "node:assert/strict";

import {
  consumeProductionEnvelopeEntryPoint,
} from "./production-envelope-consumer.js";

const baseInput = {
  envelope_id: "envelope-1",
  package_id: "package-1",
  package_version: 1,
  delegation_id: "delegation-1",
  validation_result_id: "validation-1",
  envelope_gate_id: "gate-1",
  validation_status: "caller-status-must-not-win",
  required_capabilities: "caller-capabilities-must-not-win",
  operational_corridor: "caller-corridor-must-not-win",
  lifecycle_state: "ENVELOPE_CREATED",
};

const exactReadChain = {
  validation_result: {
    validation_result_id: "validation-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_status: "VALIDATION_PASSED",
    governance_findings: null,
    operational_requirements: " planning_only ",
    capability_requirements: " engineering_planning ",
    escalations: null,
    validation_timestamp: "2026-09-24T00:00:00.000Z",
    created_at: "2026-09-24T00:00:00.000Z",
  },
  envelope_gate: {
    envelope_gate_id: "gate-1",
    package_id: "package-1",
    package_version: 1,
    delegation_id: "delegation-1",
    validation_result_id: "validation-1",
    gate_status: "OPEN",
    gate_reason: null,
    gate_decision_timestamp: "2026-09-24T00:01:00.000Z",
    created_at: "2026-09-24T00:01:00.000Z",
  },
};

test("uses exact persisted lineage and authoritative Validation semantics", () => {
  let persistedInput: Record<string, unknown> | undefined;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: (input) => {
        persistedInput = input;
        return {
          ...input,
          created_at: "2026-09-24T00:02:00.000Z",
        };
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () =>
        exactReadChain,
    },
  );

  assert.equal(result.ok, true);
  assert.equal(persistedInput?.validation_status, "VALIDATION_PASSED");
  assert.equal(
    persistedInput?.required_capabilities,
    "engineering_planning",
  );
  assert.equal(persistedInput?.operational_corridor, "planning_only");

  if (result.ok) {
    assert.equal(result.scheduler_authorized, false);
    assert.equal(result.worker_claim_authorized, false);
    assert.equal(result.orchestration_authorized, false);
    assert.equal(result.routing_authorized, false);
    assert.equal(result.assignment_authorized, false);
    assert.equal(result.lifecycle_transition_authorized, false);
    assert.equal(result.execution_authorized, false);
    assert.equal(result.downstream_governance_authorized, false);
    assert.equal(result.new_authority_introduced, false);
  }
});

test("fails closed before persistence when Validation is not passed", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          validation_status: "RESOLUTION_REQUIRED",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /VALIDATION_PASSED/);
});

test("fails closed before persistence when Gate is not OPEN", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        envelope_gate: {
          ...exactReadChain.envelope_gate,
          gate_status: "CLOSED",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /OPEN Envelope Gate/);
});

test("fails closed before persistence when capability semantics are absent", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          capability_requirements: " ",
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /capability_requirements/);
});

test("fails closed before persistence when operational semantics are absent", () => {
  let persistenceCalled = false;

  const result = consumeProductionEnvelopeEntryPoint(
    {
      ...baseInput,
      create_governance_envelope: () => {
        persistenceCalled = true;
        throw new Error("must not persist");
      },
    },
    {
      load_exact_governance_envelope_creation_read_chain: () => ({
        ...exactReadChain,
        validation_result: {
          ...exactReadChain.validation_result,
          operational_requirements: null,
        },
      }),
    },
  );

  assert.equal(result.ok, false);
  assert.equal(persistenceCalled, false);
  assert.match(result.findings[0], /operational_requirements/);
});
TS

git diff --check -- "$CONSUMER" "$TEST"
npm run check
./node_modules/.bin/tsx --test \
  db/governance-envelope-creation-read-repository.test.ts \
  server/envelope/governance-envelope-semantics.test.ts \
  "$TEST"

git add -- "$CONSUMER" "$TEST"
test "$(git diff --cached --name-only | wc -l | tr -d ' ')" = "2"
git diff --cached --name-only | grep -Fxq "$CONSUMER"
git diff --cached --name-only | grep -Fxq "$TEST"

git commit -m "Integrate Envelope eligibility into production consumer"
git push origin "$BRANCH"
