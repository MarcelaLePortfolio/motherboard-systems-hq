#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="d144fe27d"
SOURCE="server/lifecycle/production-post-envelope-lifecycle-composition.ts"
TEST="server/lifecycle/production-post-envelope-lifecycle-composition.test.ts"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

BEFORE_UNSTAGED="$(git diff --name-only)"

cat > "$SOURCE" <<'TS'
import type {
  GovernanceEnvelopeRouteResult,
} from "../routes/governance-envelope-route.js";
import type {
  ProductionLifecycleEntryPointInput,
} from "./production-lifecycle-entry-point.js";
import {
  handoffProductionEnvelopeToLifecycle,
} from "./production-envelope-lifecycle-handoff.js";

export type ProductionPostEnvelopeLifecycleCompositionInput = {
  envelope_result: GovernanceEnvelopeRouteResult;
  lifecycle_input: ProductionLifecycleEntryPointInput;
};

export type ProductionPostEnvelopeLifecycleCompositionResult =
  | {
      ok: true;
      composition: "production_post_envelope_lifecycle";
      handoff: ReturnType<typeof handoffProductionEnvelopeToLifecycle>;
      new_authority_introduced: false;
      findings: string[];
    }
  | {
      ok: false;
      composition: "production_post_envelope_lifecycle";
      handoff?: ReturnType<typeof handoffProductionEnvelopeToLifecycle>;
      new_authority_introduced: false;
      findings: string[];
    };

export function composeProductionPostEnvelopeLifecycle(
  input: ProductionPostEnvelopeLifecycleCompositionInput,
): ProductionPostEnvelopeLifecycleCompositionResult {
  if (!input.envelope_result.ok) {
    return {
      ok: false,
      composition: "production_post_envelope_lifecycle",
      new_authority_introduced: false,
      findings: [
        "Post-envelope lifecycle composition failed closed because the existing Governance Envelope route result was not successful.",
      ],
    };
  }

  const createdEnvelope = input.envelope_result.envelope.envelope;

  if (
    input.lifecycle_input.envelope_id !== createdEnvelope.envelope_id ||
    input.lifecycle_input.envelope.lifecycle_state !==
      createdEnvelope.lifecycle_state
  ) {
    return {
      ok: false,
      composition: "production_post_envelope_lifecycle",
      new_authority_introduced: false,
      findings: [
        "Post-envelope lifecycle composition failed closed because the supplied lifecycle input did not match the completed existing Envelope result.",
      ],
    };
  }

  const handoff = handoffProductionEnvelopeToLifecycle(
    input.lifecycle_input,
  );

  if (!handoff.ok) {
    return {
      ok: false,
      composition: "production_post_envelope_lifecycle",
      handoff,
      new_authority_introduced: false,
      findings: [
        "Post-envelope lifecycle composition failed closed because the existing bounded Envelope-to-Lifecycle handoff rejected the supplied existing lifecycle inputs.",
      ],
    };
  }

  return {
    ok: true,
    composition: "production_post_envelope_lifecycle",
    handoff,
    new_authority_introduced: false,
    findings: [
      "Post-envelope lifecycle composition reused the completed existing Envelope result and already-existing lifecycle inputs without creating new authority.",
    ],
  };
}
TS

cat > "$TEST" <<'TS'
import assert from "node:assert/strict";
import test from "node:test";

import {
  composeProductionPostEnvelopeLifecycle,
} from "./production-post-envelope-lifecycle-composition.js";

test("post-envelope composition reuses existing lifecycle inputs without new authority", () => {
  const result = composeProductionPostEnvelopeLifecycle({
    envelope_result: {
      ok: true,
      route: "governance_envelope_route",
      envelope: {
        ok: true,
        entry_point: "production_envelope_entry_point",
        envelope: {
          envelope_id: "env-live-composition",
          lifecycle_state: "ENVELOPE_CREATED",
        },
        findings: [],
      } as never,
      endpoint_authorized: true,
      scheduler_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      routing_authorized: false,
      assignment_authorized: false,
      lifecycle_transition_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: [],
    },
    lifecycle_input: {
      envelope_id: "env-live-composition",
      envelope: {
        lifecycle_state: "ENVELOPE_CREATED",
        required_capabilities: "engineering_planning",
        operational_corridor: "planning_only",
      },
      available_departments: ["engineering_planning"],
      department_handshake: {
        status: "ACKNOWLEDGED",
      } as never,
      persist_lifecycle_transition: (() =>
        ({
          envelope_id: "env-live-composition",
          lifecycle_state: "ASSIGNED",
          persisted_at: "2026-09-30T00:00:00.000Z",
        })) as never,
    },
  });

  assert.equal(result.new_authority_introduced, false);
});

test("post-envelope composition fails closed when envelope result is unsuccessful", () => {
  const result = composeProductionPostEnvelopeLifecycle({
    envelope_result: {
      ok: false,
      route: "governance_envelope_route",
      endpoint_authorized: true,
      scheduler_authorized: false,
      worker_claim_authorized: false,
      orchestration_authorized: false,
      routing_authorized: false,
      assignment_authorized: false,
      lifecycle_transition_authorized: false,
      execution_authorized: false,
      new_authority_introduced: false,
      findings: [],
    },
    lifecycle_input: {} as never,
  });

  assert.equal(result.ok, false);
  assert.equal(result.new_authority_introduced, false);
});
TS

printf '\n=== TARGETED VALIDATION ===\n'
npx tsx --test "$TEST"
npx tsc --noEmit

printf '\n=== AUTHORITY BOUNDARY ===\n'
grep -nE \
  'ProductionLifecycleEntryPointInput|handoffProductionEnvelopeToLifecycle|new_authority_introduced|envelope_result|lifecycle_input' \
  "$SOURCE" "$TEST"

printf '\n=== EXACT DIFF ===\n'
git diff -- "$SOURCE" "$TEST"

AFTER_UNRELATED="$(git diff --name-only | grep -vE "^${SOURCE}$|^${TEST}$" || true)"
BEFORE_UNRELATED="$(printf '%s\n' "$BEFORE_UNSTAGED" | grep -vE "^${SOURCE}$|^${TEST}$" || true)"

test "$BEFORE_UNRELATED" = "$AFTER_UNRELATED"
echo 'PREEXISTING_UNSTAGED_STATE=PRESERVED'

git add -- "$SOURCE" "$TEST"
git commit -m "Repair post-envelope lifecycle composition typing"
git push origin "$BRANCH"
