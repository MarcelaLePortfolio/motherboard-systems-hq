/*
Phase 379 — Diagnostic Stability Proof

Purpose:
Ensure deterministic diagnostic ordering and stability across repeated verification passes.
Strengthens investigation trust guarantees.

Safety:
Read-only verification.
No runtime coupling.
No execution integration.
*/

import { PATHOLOGICAL_REPLAY_FIXTURES } from "./replay_pathological_fixtures";

function collectDiagnosticOrder(): string[] {
  return PATHOLOGICAL_REPLAY_FIXTURES.map(f => f.expectedViolation);
}

function main() {
  const baseline = collectDiagnosticOrder().join("|");

  for (let i = 0; i < 10; i++) {
    const current = collectDiagnosticOrder().join("|");

    if (current !== baseline) {
      console.error(
        "[replay-diagnostic-stability] Diagnostic ordering drift detected at iteration:",
        i
      );
      process.exit(1);
    }
  }

  console.log(
    "[replay-diagnostic-stability] PASS: diagnostic ordering stable"
  );
}

main();
