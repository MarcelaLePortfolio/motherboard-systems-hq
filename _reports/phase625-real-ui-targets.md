# Phase 625 Real UI Targets

## Primary production candidates
- public/js/dashboard-tasks-widget.js
- public/js/phase565_recent_tasks_wire.js
- public/js/task-events-sse-client.js
- public/js/operatorGuidance.sse.js
- public/js/phase538_execution_inspector_retry_strategies.js
- public/js/phase535_execution_inspector_requeue.js
- public/js/phase537_execution_inspector_retry.js

## React candidate
- app/demo-runtime/page.tsx

## Phase 625 conclusion
The real live task UI is currently more likely in public/js dashboard wiring than in app/components.
Next safe step: inspect public/js/dashboard-tasks-widget.js and public/js/phase565_recent_tasks_wire.js before wiring guidance into the live surface.
