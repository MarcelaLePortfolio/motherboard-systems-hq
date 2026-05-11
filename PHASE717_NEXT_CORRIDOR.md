
# Phase 717 Next Corridor

## Stable Baseline

HEAD:

- 9798b5fd Phase 717: record retry activation archive verification

Runtime:

- healthy

Dashboard:

- healthy

Worker:

- healthy

Postgres:

- healthy

Retry contract:

- live

- validated

Retry UI:

- served

- contract-aligned

External archive:

- verified

## Current Recommended Direction

Shift from retry plumbing into execution intelligence and failure classification.

## High-ROI Targets

1. Failure classification

   - transient vs persistent

   - infrastructure vs task logic

   - retry recommendation reasoning

2. Lifecycle intelligence

   - richer task state explanations

   - retry rationale surfacing

   - operator triage hints

3. Execution evidence enrichment

   - clearer causal summaries

   - grouped retry lineage

   - execution attempt relationships

4. Safe observability expansion

   - no telemetry shell surgery

   - no broad UI rewrites

   - renderer-scoped only

## Explicitly Avoid

- broad CSS/layout rewrites

- speculative telemetry deletions

- scheduler expansion

- chat execution coupling

- hidden automation behavior

- retry mutation redesign

- multi-surface refactors without dependency mapping

## Preserved Guardrails

- truthful UI

- advisory isolation

- lightweight Git discipline

- external archive workflow

- renderer-scoped modifications

- deterministic rollback discipline

