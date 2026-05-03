# Phase 372 — Replay Diagnostic Determinism Guarantees

## Purpose

Replay diagnostics must be deterministic before any governance investigation tooling depends on them.

This document defines the determinism guarantees required for replay violation reporting.

## Determinism guarantees

Replay verification must guarantee:

Stable violation ordering  
Stable violation classification  
Stable violation counts  
Stable diagnostic codes  
Stable fixture outcomes  

Identical input must always produce identical:

Violation lists  
Violation order  
Diagnostic codes  
Summary counts  

## Required ordering rules

Violations must be reported in deterministic order:

1 structural replay violations  
2 replay metadata violations  
3 event structural violations  
4 event ordering violations  
5 sequence violations  
6 timestamp violations  
7 unknown violations  

Within a category:

Violations must be ordered by event index.

## Diagnostic stability requirement

Replay diagnostics must never depend on:

Object iteration order  
Map iteration order  
Runtime hash ordering  
Engine differences  

Diagnostics must depend only on:

Replay content  
Event index  
Sequence values  
Timestamp values  

## Investigation safety requirement

Replay diagnostics must never:

Mutate replay data  
Trigger execution  
Trigger routing  
Trigger reducers  
Trigger agents  

Replay verification remains pure analysis.

## Authority boundary

Replay diagnostics have:

No execution authority  
No decision authority  
No mutation authority  
No routing authority  

Replay diagnostics are classification only.

## Status

Replay diagnostics are now classified as:

Deterministic investigation output.

