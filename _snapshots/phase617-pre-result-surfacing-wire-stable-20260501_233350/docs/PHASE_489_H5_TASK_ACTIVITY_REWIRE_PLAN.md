PHASE 489 — H5 TASK ACTIVITY REWIRE PLAN

STATUS:
READY TO BEGIN

────────────────────────────────

OBJECTIVE

Restore the Task Activity panel as a real telemetry surface backed by live system data.

────────────────────────────────

SCOPE

This corridor is limited to the Task Activity panel only:

• Task Activity tab
• task-activity-graph canvas
• any existing read-only data source already intended for that graph

────────────────────────────────

CONSTRAINTS

• Read-only UI/data reconnection only
• No backend mutation unless required to complete existing schema expectations
• No governance mutation
• No execution mutation
• No contract redesign
• One hypothesis at a time

────────────────────────────────

METHOD

1. Trace the current Task Activity graph client
2. Verify which route / endpoint / SSE stream it expects
3. Confirm whether the client is mounting and receiving data
4. Patch only the missing wiring or schema prerequisite
5. Rebuild and validate visually

────────────────────────────────

SUCCESS CRITERIA

• Task Activity graph renders real data
• No regressions to Recent Tasks
• No regressions to Task History / Events
• No regressions to Operator Guidance
• Telemetry Console remains layout-stable

────────────────────────────────

STATE

CONTROLLED
SINGLE-HYPOTHESIS
READY

