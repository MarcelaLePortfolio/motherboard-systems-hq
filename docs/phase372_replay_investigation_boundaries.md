# Phase 372 — Replay Investigation Boundaries

## Purpose

This document defines the strict boundaries of the replay investigation subsystem to prevent accidental expansion into execution or governance authority.

Replay investigation exists only to:

Analyze replay structure  
Classify violations  
Produce deterministic diagnostics  
Support governance investigation understanding  

Replay investigation does NOT exist to:

Make decisions  
Block execution  
Allow execution  
Route tasks  
Modify state  
Influence agents  

## Investigation boundary definition

Replay investigation is classified as:

A passive cognition surface.

It observes recorded execution history but does not interact with live execution.

## Hard boundaries

Replay investigation must never:

Call reducers  
Call workers  
Call runtime execution paths  
Modify registries  
Modify tasks  
Modify agents  
Modify telemetry  

Replay investigation must never become part of execution routing.

## Allowed interactions

Replay investigation may only interact with:

Replay data structures  
Verification utilities  
Diagnostic classification logic  
Fixture proof tooling  
Governance investigation readers  

All interactions must remain read-only.

## Governance boundary

Replay investigation may support governance understanding but must never become governance enforcement.

Replay investigation may:

Explain failures  
Classify failures  
Support operator understanding  

Replay investigation may NOT:

Block execution  
Approve execution  
Gate execution  
Authorize execution  

## Operator boundary

Replay investigation may provide investigation outputs to operator tooling but must never take operator actions.

Replay investigation produces information only.

## Future integration rule

If replay investigation is referenced by future systems:

Integration must remain:

Read-only  
Non-authoritative  
Non-executing  
Non-mutating  

## Architectural classification

Replay investigation is formally classified as:

Investigation subsystem  
Deterministic cognition utility  
Governance investigation primitive  
Non-authoritative analysis layer  

## Phase closure status

Replay investigation scope is now explicitly bounded.

Phase 372 investigation corridor is now considered structurally defined.

