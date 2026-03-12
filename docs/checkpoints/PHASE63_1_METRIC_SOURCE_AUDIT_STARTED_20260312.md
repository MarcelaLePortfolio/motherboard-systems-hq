# PHASE 63.1 METRIC SOURCE AUDIT STARTED
Date: 2026-03-12

## Objective

Begin Phase 63.1 Metrics Data Integrity by tracing the canonical source and calculation path for each System Metrics tile.

## Audit Targets

- Active Agents
- Tasks Running
- Success Rate
- Latency

## Rules

No layout mutation.
No ID changes.
No structural wrappers.
Audit first, change second.

## Verification Baseline

- scripts/verify-phase63-telemetry-baseline.sh

## Intent

Identify:
- current event source
- current in-browser calculation
- duplicate or fallback logic
- whether each metric is canonical or provisional
