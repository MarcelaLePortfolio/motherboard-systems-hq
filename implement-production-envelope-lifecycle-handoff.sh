#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="66c972195"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git status --porcelain)"

cat > server/lifecycle/production-envelope-lifecycle-handoff.ts <<'TS'
import {
  consumeProductionLifecycleEntryPoint,
  type ConsumeProductionLifecycleEntryPointInput,
  type ConsumeProductionLifecycleEntryPointResult,
} from "./production-lifecycle-entry-point.js";

export type ProductionEnvelopeLifecycleHandoffInput =
  ConsumeProductionLifecycleEntryPointInput;

export type ProductionEnvelopeLifecycleHandoffResult =
  ConsumeProductionLifecycleEntryPointResult & {
    handoff: "production_envelope_to_lifecycle";
    new_authority_introduced: false;
  };

export function handoffProductionEnvelopeToLifecycle(
  input: ProductionEnvelopeLifecycleHandoffInput,
): ProductionEnvelopeLifecycleHandoffResult {
  const result = consumeProductionLifecycleEntryPoint(input);

  return {
    ...result,
    handoff: "production_envelope_to_lifecycle",
    new_authority_introduced: false,
  };
}
TS

cat > server/lifecycle/production-envelope-lifecycle-handoff.test.ts <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  handoffProductionEnvelopeToLifecycle,
} from "./production-envelope-lifecycle-handoff.js";

test("production envelope lifecycle handoff preserves bounded authority", () => {
  const result = handoffProductionEnvelopeToLifecycle({
    envelope_id: "env-handoff-test",
    envelope: {
      lifecycle_state: "ENVELOPE_CREATED",
      required_capabilities: "engineering_planning",
      operational_corridor: "planning_only",
    },
    available_departments: ["engineering_planning"],
    available_actors: ["cade"],
    department_handshake: {
      acknowledgement_status: "ACKNOWLEDGED",
      capability_status: "CAPABILITY_CONFIRMED",
      response_basis: "existing department assignment readiness",
    },
    persist: () => ({
      envelope_id: "env-handoff-test",
      previous_lifecycle_state: "ENVELOPE_CREATED",
      lifecycle_state: "ASSIGNED",
      transition: "ENVELOPE_CREATED_TO_ASSIGNED",
      persisted_at: "2026-09-29T00:00:00.000Z",
      mutation_authorized: false,
      execution_authorized: false,
    }),
  });

  assert.equal(result.ok, true);
  assert.equal(result.handoff, "production_envelope_to_lifecycle");
  assert.equal(result.new_authority_introduced, false);
  assert.equal(result.scheduler_authorized, false);
  assert.equal(result.worker_claim_authorized, false);
  assert.equal(result.execution_authorized, false);
});

test("production envelope lifecycle handoff fails closed without assignment readiness", () => {
  const result = handoffProductionEnvelopeToLifecycle({
    envelope_id: "env-handoff-blocked",
    envelope: {
      lifecycle_state: "ENVELOPE_CREATED",
      required_capabilities: "engineering_planning",
      operational_corridor: "planning_only",
    },
    available_departments: ["engineering_planning"],
    available_actors: ["cade"],
    persist: () => {
      throw new Error("persistence must not be reached");
    },
  });

  assert.equal(result.ok, false);
  assert.equal(result.handoff, "production_envelope_to_lifecycle");
  assert.equal(result.new_authority_introduced, false);
});
TS

printf '\n=== VALIDATE TARGETED HANDOFF ===\n'
npx tsc --noEmit
node --test \
  dist/server/lifecycle/production-envelope-lifecycle-handoff.test.js 2>/dev/null || \
npx tsx --test server/lifecycle/production-envelope-lifecycle-handoff.test.ts

printf '\n=== VERIFY AUTHORITY BOUNDARY ===\n'
grep -nE \
  'new_authority_introduced|scheduler_authorized|worker_claim_authorized|execution_authorized|consumeProductionLifecycleEntryPoint' \
  server/lifecycle/production-envelope-lifecycle-handoff.ts \
  server/lifecycle/production-envelope-lifecycle-handoff.test.ts

printf '\n=== DIFF ===\n'
git diff -- \
  server/lifecycle/production-envelope-lifecycle-handoff.ts \
  server/lifecycle/production-envelope-lifecycle-handoff.test.ts

git add -- \
  server/lifecycle/production-envelope-lifecycle-handoff.ts \
  server/lifecycle/production-envelope-lifecycle-handoff.test.ts

git commit -m "Add bounded production envelope lifecycle handoff"
git push origin feature/support-source-references-runtime
