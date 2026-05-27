STATE NOTE — PHASE 65 EXECUTION START
Tasks Running Hydration
Date: 2026-03-14

STATUS

Phase 65 has formally begun.

This checkpoint exists to lock the first execution target before any telemetry code mutation.

TARGET

Hydrate the "Tasks Running" metric without:

- layout mutation
- CSS mutation
- ID mutation
- script mount order changes
- tab lifecycle changes

AUTHORIZED SCOPE

Telemetry/data binding only.

Primary target files remain:

- public/js/phase61_recent_history_wire.js
- public/js/phase61_tabs_workspace.js

Optional isolated binder allowed only if it can be mounted without violating protection rules:

- public/js/phase65_metrics_tasks_running.js

IMPLEMENTATION MODEL

Preferred runtime model:

- maintain active task set
- add on running/started/queued transition
- remove on completed/failed/cancelled transition
- render metric as active set size
- fail safe to 0

PROTECTION REQUIREMENTS

Before commit:

- bash scripts/_local/phase64_7_dashboard_layout_script_mount_guard.sh
- bash scripts/_local/phase64_8_pre_push_contract_guard.sh

Then:

- docker compose build dashboard
- docker compose up -d dashboard

Then verify:

- dashboard loads
- tabs remain interactive
- Task Events remains healthy
- idle state shows 0 running tasks

SUCCESS CONDITION

"Tasks Running" becomes live while all Phase 64 protections remain green.

NO-ECHO RULE

Do not narrate prior phases during implementation.
Resume directly at code mutation and verification.

