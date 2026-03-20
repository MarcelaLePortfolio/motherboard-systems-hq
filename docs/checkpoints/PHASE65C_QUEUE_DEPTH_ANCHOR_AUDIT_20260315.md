PHASE 65C — QUEUE DEPTH ANCHOR AUDIT
Date: 2026-03-15

OBSERVED

Current protected metrics row exposes exactly four anchors:

metric-agents   → Active Agents
metric-tasks    → Tasks Running
metric-success  → Success Rate
metric-latency  → Latency (ms)

OWNERSHIP STATUS

metric-tasks is already transferred to telemetry ownership.

metric-success and metric-latency still have live references in agent-status-row.js and remain occupied surfaces until ownership transfer is performed explicitly.

QUEUE DEPTH STATUS

Queue Depth does not currently have a dedicated protected anchor.

CONSTRAINT

Queue Depth cannot be hydrated safely until one of the following is done:

1. A formal ownership transfer is made for an existing non-telemetry metric tile, or
2. A new layout phase authorizes an additional metric anchor.

PHASE 65C DECISION

No direct Queue Depth hydration will occur yet.

Immediate next work:
inspect metric-success and metric-latency writer ownership in agent-status-row.js,
then select the safer transfer candidate for Phase 65C.

RULE

Do not write Queue Depth into an occupied tile without explicit ownership transfer.
Do not mutate layout to create a new tile during Phase 65C.
