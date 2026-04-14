PHASE 489 — H2 TELEMETRY REWIRE PLAN

STATUS:
READY TO BEGIN

────────────────────────────────

OBJECTIVE

Restore live, read-only telemetry visibility across the dashboard telemetry workspace
by reconnecting existing UI panels to their current data sources without changing:

• backend contracts
• governance logic
• approval logic
• execution logic
• mutation behavior

────────────────────────────────

SCOPE

This corridor is LIMITED to telemetry visibility surfaces only:

• Recent Tasks
• Task History / Activity
• Task Events panel
• Existing metric surfaces if touched by the same visibility path

────────────────────────────────

CONSTRAINTS

• Read-only UI/data reconnection only
• No backend mutation
• No contract/schema changes
• No governance mutation
• No execution mutation
• No new business logic

────────────────────────────────

METHOD

1. Trace served telemetry panel anchors
2. Identify existing client scripts that should populate them
3. Verify actual served routes / SSE endpoints
4. Reconnect only the missing UI bindings
5. Validate panel population without introducing fallback corruption

────────────────────────────────

SUCCESS CRITERIA

• Telemetry workspace panels populate from real live sources
• No placeholder-only empty state when data exists
• No regressions to Operator Guidance
• No layout regressions
• Dashboard remains deterministic and replay-safe

────────────────────────────────

STATE

READY
CONTROLLED
SINGLE-HYPOTHESIS

