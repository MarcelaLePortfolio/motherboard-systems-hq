# PHASE 63.3 HEARTBEAT CONSUMER DEPENDENCY AUDIT
Date: 2026-03-12

## Summary

Continue Phase 63.3 with a narrow consumer dependency audit now that named `ops.heartbeat` delivery is confirmed.

## Verified Upstream State

- named `ops.heartbeat` reaches SSE clients
- transport `heartbeat` remains present as keepalive
- producer mutation is not required for named heartbeat preservation

## Audit Focus

Determine current browser dependency on:

- `ops.heartbeat`
- `lastHeartbeatAt`
- `mb:ops:update`
- `lastOpsHeartbeat`
- `lastOpsStatusSnapshot`

## Decision Target

Clarify whether current consumers should intentionally rely on:

- named application heartbeat
- snapshot state only
- both
- or neither

## Rule

Audit only before implementation.

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.

## Findings — Consumer Reality (Phase 63.3)

Current dashboard consumers do **not** directly depend on named `ops.heartbeat`.

Observed dependencies:

OPS pill:
- depends on `lastOpsHeartbeat` global
- updated from any OPS SSE message
- not tied to heartbeat event specifically

Agent Pool:
- depends on OPS snapshot payload
- derives freshness from agent timestamps
- independent of heartbeat event

Custom Event:
- `mb:ops:update` used as generic state fan-out
- not heartbeat specific

## Conclusion

Current architecture already favors:

snapshot-driven telemetry
with heartbeat acting only as transport liveness signal.

No refactor required.

## Phase 63.3 Direction

Telemetry enrichment should continue toward:

consumer clarity
null-state semantics
metric provenance mapping

Heartbeat refactor unnecessary unless future consumers require it.
