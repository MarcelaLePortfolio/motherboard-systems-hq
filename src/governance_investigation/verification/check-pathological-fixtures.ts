/*
Phase 374 — Pathological Fixture Verification Proof

Purpose:
Deterministic validation that all pathological fixtures map to known diagnostic codes.

Safety:
Read-only verification.
No runtime coupling.
No execution integration.
*/

import { PATHOLOGICAL_REPLAY_FIXTURES } from "./replay_pathological_fixtures";
import { REPLAY_VIOLATION_CODES } from "./replay_violation_codes";

function main() {
  let failures = 0;

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

  console.log("[replay-pathological-check] PASS: all fixtures valid");
}

main();
