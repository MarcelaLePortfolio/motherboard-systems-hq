PHASE 489 — H2 TASK EVENTS RESTORE PLAN

STATUS:
APPLYING FIRST TELEMETRY REWIRE

────────────────────────────────

HYPOTHESIS

The telemetry workspace is partially wired, but the Task Events surface is not
mounted to its existing read-only client.

────────────────────────────────

ACTION

• Auto-discover the existing task-events client under public/js
• Mount it into the served dashboard
• Preserve current backend routes and contracts
• Keep all changes UI-only and read-only

────────────────────────────────

SUCCESS CRITERIA

• Task Events panel begins populating from live event data
• No regression to Operator Guidance
• No regression to Recent Tasks / Task History panels
• No backend mutation

