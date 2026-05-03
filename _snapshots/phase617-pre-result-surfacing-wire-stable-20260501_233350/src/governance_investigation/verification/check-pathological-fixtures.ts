/*
Phase 394 — Pathological Fixture Diagnostic Module Resolution Hardening

Purpose:
Resolve diagnostic code module shape deterministically and fail clearly when
the diagnostic registry is unavailable or malformed.

Safety:
Read-only verification.
No runtime coupling.
No execution integration.
*/

import { PATHOLOGICAL_REPLAY_FIXTURES } from "./replay_pathological_fixtures";
import * as replayViolationModule from "./replay_violation_codes";

type ViolationCodeMap = Record<string, unknown>;

function resolveViolationCodeMap(): ViolationCodeMap {
  const candidates: unknown[] = [
    (replayViolationModule as { REPLAY_VIOLATION_CODES?: unknown }).REPLAY_VIOLATION_CODES,
    (replayViolationModule as { default?: unknown }).default,
    replayViolationModule
  ];

  for (const candidate of candidates) {
    if (candidate && typeof candidate === "object") {
      return candidate as ViolationCodeMap;
    }
  }

  console.error(
    "[replay-pathological-check] Diagnostic code registry unavailable or malformed"
  );
  process.exit(1);
}

function assertDeterministicOrdering() {
  const ids = PATHOLOGICAL_REPLAY_FIXTURES.map((fixture) => fixture.id);
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

  const violationCodes = resolveViolationCodeMap();

  for (const fixture of PATHOLOGICAL_REPLAY_FIXTURES) {
    if (!(fixture.expectedViolation in violationCodes)) {
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

  console.log(
    "[replay-pathological-check] PASS: deterministic ordering + valid diagnostics"
  );
}

main();
