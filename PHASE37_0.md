# Phase 37.0 — Run Timeline Integrity (Planning Only)

## Status
📝 Planning only — NO implementation in this phase.

## Context / Baseline
- Phase 36 is complete and golden-tagged: v36.4-phase36-run-list-observability
- Existing contract: **single-writer** task_events + **run_view** as canonical read-only projection

## Next Invariant-Level Objective
Make **run_view explainable, auditable, and temporally coherent** by defining a strict, invariant-backed relationship between:
1) the immutable event stream (task_events), and
2) the projected run snapshot (run_view), and
3) any read-only APIs that surface run state.

In short: **Every field in run_view must be traceable to a specific event (or deterministic rule), and the run snapshot must not “time-travel.”**

## Why this is the next milestone
Phase 36 made runs observable (single + list). Phase 37 should ensure that what we observe is:
- provenance-backed (no mystery fields),
- deterministic under concurrency (single-writer),
- and stable under repeated reads (no contradictory snapshots).

## Proposed Scope (Planning Only)
Define the invariants, acceptance checks, and constraints needed to guarantee:

### A) Provenance Invariant (Explainability)
For each run_id returned by run_view:
- Each projected field is either:
  - directly sourced from one or more task_events payloads, OR
  - a deterministic SQL derivation whose inputs are fully specified (no “JS inferred state”).

### B) Temporal Coherence Invariant (No Time Travel)
For each run_id:
- The projection must be consistent with an ordered event timeline.
- The “latest” event used for projection is unambiguous (strict ordering key defined).
- Re-reading run_view at the same database state yields the same values (deterministic).

### C) Projection Completeness Invariant (Closed World)
For each run_id:
- The snapshot must be computable using only the sanctioned inputs (task_events + tasks + deterministic joins).
- No hidden state, no caches, no worker-only memory.

## Non-Goals (Explicit)
- No schema changes in this phase
- No new endpoints implemented in this phase
- No UI/dashboard changes
- No new worker behavior
- No materialized views or background jobs (unless explicitly planned for a later phase)

## Planning Deliverables (What we produce in Phase 37.0)
1) **A written “Run Projection Contract”** (this doc) that:
   - enumerates all fields in run_view and declares provenance expectations
   - defines the ordering key for events (e.g., (ts, id) or equivalent) as the canonical tie-breaker
2) **Acceptance checks** (described, not implemented) that can be executed via SQL:
   - determinism checks on ordering
   - “traceability” queries for sample runs
   - “no time travel” consistency checks across repeated reads
3) **Implementation boundary for Phase 37.x**
   - If we proceed, Phase 37.1 would implement only the minimal SQL/view changes (if any) required to enforce the contract, staying read-only and single-writer compatible.

## Candidate Acceptance Checks (Planning-Only Definitions)

### 1) Ordering Determinism Check
- Verify task_events ordering is total for events contributing to a run projection.
- Define tie-breaker explicitly (e.g., ORDER BY ts ASC, id ASC).

### 2) Traceability Check (Spot Audit)
- For a given run_id:
  - list the contributing events in canonical order
  - demonstrate how each run_view field is derived

### 3) Snapshot Coherence Check
- For a given run_id:
  - ensure projected “latest” fields correspond to the last relevant event by canonical order

## Protocols (Hard Rules)
- Golden tags are immutable. Never retag or rewrite: v36.4-phase36-run-list-observability is authoritative.
- Phase scope is strict: Phase 37.0 produces documentation only.
- One hypothesis at a time; no layered speculative fixes.
- If later implementation phases fail 3 times per hypothesis, revert to last known stable baseline and reassess.

