import assert from "node:assert/strict";
import test from "node:test";

import { evaluateExecutionAuthority } from "./execution-authority-core";

const authorityFields = [
  "scheduler_authorized",
  "routing_authorized",
  "worker_claim_authorized",
  "orchestration_authorized",
  "execution_authorized",
] as const;

test("downstream authority requires plan review and explicit preview confirmation", () => {
  const scenarios = [
    {
      input: { plan_review_ready: false, preview_confirmed: false },
      expected: false,
    },
    {
      input: { plan_review_ready: true, preview_confirmed: false },
      expected: false,
    },
    {
      input: { plan_review_ready: false, preview_confirmed: true },
      expected: false,
    },
    {
      input: { plan_review_ready: true, preview_confirmed: true },
      expected: true,
    },
  ];

  for (const { input, expected } of scenarios) {
    const result = evaluateExecutionAuthority(input);

    for (const field of authorityFields) {
      assert.equal(
        result[field],
        expected,
        `${field} must equal ${expected} for ${JSON.stringify(input)}`,
      );
    }

    assert.equal(result.preview_confirmed, input.preview_confirmed);
    assert.equal(result.plan_review_ready, input.plan_review_ready);
    assert.equal(result.source, "execution-authority-core");
  }
});

test("missing preview confirmation fails closed", () => {
  const result = evaluateExecutionAuthority({
    plan_review_ready: true,
    preview_confirmed: false,
  });

  assert.equal(result.execution_authorized, false);
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.reason, "Preview not confirmed");
});

test("missing plan readiness fails closed", () => {
  const result = evaluateExecutionAuthority({
    plan_review_ready: false,
    preview_confirmed: true,
  });

  assert.equal(result.execution_authorized, false);
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.routing_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.orchestration_authorized, false);
  assert.equal(result.reason, "Plan not ready");
});
