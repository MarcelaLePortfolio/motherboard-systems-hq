/*
Phase 378 — Replay Pathological Proof Suite

Purpose:
Provide a single deterministic verification entrypoint for pathological replay proof coverage.
Aggregates structural validity, deterministic ordering, and fixture reproducibility checks.

Safety:
Verification only.
Read-only execution.
No runtime coupling.
No reducer coupling.
No execution integration.
No mutation surfaces.
*/

import "./check-pathological-fixtures";
import "./check-pathological-fixture-reproducibility";

console.log("[replay-pathological-proof-suite] PASS: pathological replay proof suite completed");
