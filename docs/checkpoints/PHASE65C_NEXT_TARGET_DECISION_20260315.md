PHASE 65C — NEXT TARGET DECISION
Date: 2026-03-15

DECISION

Queue Depth is blocked by anchor availability.

Current protected metric anchors:

metric-agents
metric-tasks
metric-success
metric-latency

STATUS

metric-tasks is already telemetry-owned.
metric-success is still owned by agent-status-row.js.
metric-latency is still owned by agent-status-row.js.

SAFER NEXT TARGET

metric-success ownership transfer.

WHY THIS IS SAFER

1. It already derives only from task terminal events.
2. It does not depend on task start time capture.
3. It does not require latency formatting logic.
4. It is lower complexity than metric-latency.
5. It follows the same ownership-transfer pattern used for metric-tasks.

PHASE 65C ORDER

1. Transfer metric-success ownership to telemetry.
2. Verify no regression.
3. Reassess whether metric-latency should transfer next.
4. Only then decide whether Queue Depth can claim a tile without violating ownership or frozen layout rules.

RULE

Do not implement Queue Depth yet.
Do not repurpose a protected tile without explicit ownership transfer.
