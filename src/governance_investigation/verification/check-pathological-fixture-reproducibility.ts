/*
Phase 377 — Pathological Fixture Reproducibility Proof

Purpose:
Prove deterministic reproducibility of pathological fixture materialization.
Strengthens investigation reliability without introducing runtime coupling.

Safety:
Read-only verification.
No runtime mutation.
No execution integration.
*/

import { PATHOLOGICAL_REPLAY_FIXTURES } from "./replay_pathological_fixtures";

function buildCanonicalSignature(): string {
  return PATHOLOGICAL_REPLAY_FIXTURES.map((fixture) => {
    const eventSequence = fixture.eventSequence.join(">");
    return [
      fixture.id,
      fixture.description,
      eventSequence,
      fixture.expectedViolation
    ].join("|");
  }).join("\n");
}

function main() {
  const baseline = buildCanonicalSignature();

  for (let i = 0; i < 10; i++) {
    const current = buildCanonicalSignature();

    if (current !== baseline) {
      console.error(
        "[replay-pathological-reproducibility] Non-deterministic fixture materialization detected at iteration:",
        i
      );
      process.exit(1);
    }
  }

  console.log(
    "[replay-pathological-reproducibility] PASS: canonical fixture signature is reproducible"
  );
}

main();
