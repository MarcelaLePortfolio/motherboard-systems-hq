/*
Phase 376 — Pathological Fixture Deterministic Ordering Proof

Purpose:
Add deterministic ordering verification to ensure fixture stability.
Prevents non-deterministic drift in verification results.

Safety:
Read-only verification.
No runtime coupling.
No execution integration.
*/

import { PATHOLOGICAL_REPLAY_FIXTURES } from "./replay_pathological_fixtures";
import { REPLAY_VIOLATION_CODES } from "./replay_violation_codes";

function assertDeterministicOrdering() {
  const ids = PATHOLOGICAL_REPLAY_FIXTURES.map(f => f.id);
  const sorted = [...ids].sort();

  for (let i = 0; i < ids.length; i++) {
    if (ids[i] !== sorted[i]) {
      console.error(
        "[replay-pathological-check] Non-deterministic fixture ordering detected:",
        ids[i],
        "expected position:",
        sorted[i]
      );
      process.exit(1);
    }
  }
}

function main() {
  let failures = 0;

  assertDeterministicOrdering();

  for (const fixture of PATHOLOGICAL_REPLAY_FIXTURES) {
    if (!REPLAY_VIOLATION_CODES[fixture.expectedViolation]) {
      console.error(
        "[replay-pathological-check] Unknown violation code:",
        fixture.id,
        fixture.expectedViolation
      );
      failures++;
    }
  }

  if (failures > 0) {
    console.error("[replay-pathological-check] FAIL:", failures, "issues detected");
    process.exit(1);
  }

  console.log("[replay-pathological-check] PASS: deterministic ordering + valid diagnostics");
}

main();
