/*
Phase 381 — Replay Verification Proof Suite Aggregator

Purpose:
Create deterministic master entrypoint for all replay verification proofs.
Establishes a single operator-trusted verification surface.

Safety:
Verification only.
Read-only aggregation.
No runtime coupling.
No execution integration.
No mutation surfaces.
*/

import "./run-replay-pathological-proof-suite";
import "./run-replay-diagnostic-stability-proof";

console.log("[replay-verification-proof-suite] PASS: all replay verification proofs completed");
