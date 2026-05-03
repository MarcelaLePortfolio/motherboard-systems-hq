PHASE 62B — ACTIVE AGENTS SOURCE AUDIT
Date: 2026-03-11

────────────────────────────────

PURPOSE

Document the confirmed source path for the Phase 62B Active Agents metric before hydration begins.

This audit is read-only.
No implementation changes were made.

────────────────────────────────

AUDIT RESULT

Confirmed primary source path:

/events/ops

Consumed by:

public/js/agent-status-row.js

The Agent Pool already receives live agent status updates from the OPS SSE stream.

────────────────────────────────

CONFIRMED FINDINGS

public/js/agent-status-row.js:

• opens EventSource("/events/ops")
• consumes payload.agents maps when present
• also consumes single-agent updates
• supports agent keys:
  Matilda
  Atlas
  Cade
  Effie
• reads status-like fields including:
  status
  state
  level
  health
  mode

Current render path classifies status into:

• online
• pending
• error
• unknown

This confirms that Active Agents hydration should begin from the existing OPS SSE path rather than from a new endpoint.

────────────────────────────────

IMPORTANT OPEN QUESTION

The current client-side render path clearly receives live status values.

However, timestamp availability is not yet confirmed.

Not yet proven in current audit:

• last_seen
• last_activity
• lastHeartbeatAt
• per-agent timestamp
• updatedAt

This matters because the Phase 62 metrics contract defines:

Active Agents =
agents with activity in the last 60 seconds

Therefore, the next audit step is to inspect the upstream /events/ops producer and verify whether per-agent activity timestamps already exist.

────────────────────────────────

IMPLEMENTATION IMPLICATION

Active Agents is still the correct first Phase 62B hydration target.

Preferred implementation path:

1 Confirm upstream timestamp availability
2 If timestamps exist:
  implement contract exactly
3 If timestamps do not exist:
  decide whether to
  • add upstream timestamp support
  or
  • use temporary fallback based on trustworthy live status

No decision taken yet.

────────────────────────────────

RISK ASSESSMENT

Low risk.

Reason:

• source path identified
• UI consumer identified
• no layout changes required
• first hydration target remains JS-only

────────────────────────────────

NEXT RECOMMENDED ACTION

Inspect the /events/ops producer to determine whether agent activity timestamps are already emitted upstream.

