#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="045e4f637"
SOURCE="server/lifecycle/production-envelope-lifecycle-handoff.ts"
TEST="server/lifecycle/production-envelope-lifecycle-handoff.test.ts"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"

cat > "$SOURCE" <<'TS'
import {
  invokeProductionLifecycleEntryPoint,
  type ProductionLifecycleEntryPointInput,
  type ProductionLifecycleEntryPointResult,
} from "./production-lifecycle-entry-point.js";

export type ProductionEnvelopeLifecycleHandoffInput =
  ProductionLifecycleEntryPointInput;

export type ProductionEnvelopeLifecycleHandoffResult =
  ProductionLifecycleEntryPointResult & {
    handoff: "production_envelope_to_lifecycle";
    new_authority_introduced: false;
  };

export function handoffProductionEnvelopeToLifecycle(
  input: ProductionEnvelopeLifecycleHandoffInput,
): ProductionEnvelopeLifecycleHandoffResult {
  const result = invokeProductionLifecycleEntryPoint(input);

  return {
    ...result,
    handoff: "production_envelope_to_lifecycle",
    new_authority_introduced: false,
  };
}
TS

cat > "$TEST" <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  handoffProductionEnvelopeToLifecycle,
} from "./production-envelope-lifecycle-handoff.js";

test("production envelope lifecycle handoff preserves existing lifecycle authority only", () => {
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
    persist_lifecycle_transition: () => ({
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

test("production envelope lifecycle handoff fails closed without existing assignment readiness", () => {
  const result = handoffProductionEnvelopeToLifecycle({
    envelope_id: "env-handoff-blocked",
    envelope: {
      lifecycle_state: "ENVELOPE_CREATED",
      required_capabilities: "engineering_planning",
      operational_corridor: "planning_only",
    },
    available_departments: ["engineering_planning"],
    available_actors: ["cade"],
    persist_lifecycle_transition: () => {
      throw new Error("persistence must not be reached");
    },
  });

  assert.equal(result.ok, false);
  assert.equal(result.handoff, "production_envelope_to_lifecycle");
  assert.equal(result.new_authority_introduced, false);
});
TS

printf '\n=== TARGETED VALIDATION ===\n'
npx tsx --test "$TEST"
npx tsc --noEmit

printf '\n=== AUTHORITY BOUNDARY ===\n'
grep -nE \
  'invokeProductionLifecycleEntryPoint|new_authority_introduced|scheduler_authorized|worker_claim_authorized|execution_authorized|persist_lifecycle_transition' \
  "$SOURCE" "$TEST"

printf '\n=== EXACT DIFF ===\n'
git diff -- "$SOURCE" "$TEST"

git add -- "$SOURCE" "$TEST"
git commit -m "Repair production envelope lifecycle entrypoint binding"
git push origin "$BRANCH"
