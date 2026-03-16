PHASE 65B.6 — METRIC-AGENTS DUPLICATE WRITER DETECTED
Date: 2026-03-15

Status:
metric-agents inspection is COMPLETE.

Finding:
Duplicate writers are present for metric-agents.

Writers detected:
1. public/js/agent-status-row.js
   - setMetricText(activeAgentsMetricEl, String(count))
   - reset path also writes "—"

2. public/js/phase64_agent_activity_wire.js
   - renderMetricAgents()
   - el.textContent = String(getActiveAgentCount())

Risk:
metric-agents is not safe for further telemetry expansion until ownership is consolidated.

Safe conclusion:
Do not add any new metric-agents writers.
Do not move ownership yet without a narrow transfer step.

Recommended owner:
public/js/phase64_agent_activity_wire.js

Reason:
Its metric-agents value is derived from the same agent activity state used to render the agent pool.
That is a tighter ownership boundary than the legacy writer in agent-status-row.js.

Next safe boundary:
1 remove legacy metric-agents writer from agent-status-row.js
2 preserve phase64_agent_activity_wire.js as sole owner
3 run protection gate
4 rebuild and verify
5 only then continue telemetry expansion

Rules:
- no layout mutation
- no protected file edits
- no fix-forward behavior
- one ownership transfer only
