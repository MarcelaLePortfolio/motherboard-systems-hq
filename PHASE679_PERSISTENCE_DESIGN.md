# Phase 679 — Persistence-Aware Guidance History (Design Only)

## Objective

Design a durable guidance history layer that enables persistence-aware coherence aggregation without modifying current execution behavior.

## Constraints

- No execution pipeline changes
- No database mutations (design only)
- No UI coupling changes
- Must remain compatible with current in-memory guidanceHistory
- Must fail safely to in-memory mode

## Recommended Architecture

Introduce a storage adapter:

server/guidance/guidance-history-store.mjs

## Storage Strategy (Recommended)

Dual-layer model:

1. In-memory (existing)
2. Durable append-only JSONL

Reason:
- JSONL preserves temporal order
- Simple append semantics
- Easy replay + inspection
- No schema migration required

## JSONL Record Shape (Proposed)

Each line = one flattened guidance signal:

{
  "timestamp": "ISO8601",
  "task_id": "string",
  "subsystem": "string",
  "signal_type": "string",
  "severity": "string",
  "message": "string"
}

## Write Strategy

Triggered inside recordGuidanceHistory:

- Flatten snapshot → events
- Append each event as JSON line
- Non-blocking write (fire-and-forget or buffered)

## Read Strategy (Future)

Expose:

readRecentEvents(limit, timeWindow)

Used by coherence layer in later phase.

## Merge Strategy (Future)

Coherence input:

combined = [
  ...inMemoryEvents,
  ...persistedEvents
]

Rules:
- Deduplicate by identity key
- Preserve earliest first_seen
- Preserve latest last_seen
- Sum counts

## Retention Strategy

- JSONL capped by:
  - max lines OR
  - rolling time window (e.g., last 24h)
- Rotation handled separately (future phase)

## Source Attribution

Add field:

source: "memory" | "jsonl" | "merged"

Expose in coherence response.

## Failure Mode

If JSONL unavailable:

- Log warning
- Continue using in-memory history
- No runtime interruption

## Deferred Decisions

- File location (e.g., ./data/guidance-history.jsonl)
- Rotation strategy
- Compression strategy
- Indexing (if needed)

## Non-Goals

- No immediate implementation
- No DB schema introduction
- No change to coherence algorithm
- No change to SSE or UI

## Exit Criteria

Design is:

- explicit
- minimal
- reversible
- non-invasive

Ready for safe implementation in Phase 680.
