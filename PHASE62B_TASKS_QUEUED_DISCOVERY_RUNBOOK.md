PHASE 62B — TASKS QUEUED
DISCOVERY RUNBOOK

PURPOSE

Run the queued-metric discovery script.
Capture exact queued-state definition.
Locate current hydration surface before any code wiring.

RUN COMMAND

./scripts/_local/phase62b_tasks_queued_discovery.sh | tee /tmp/phase62b_tasks_queued_discovery.out

REQUIRED REVIEW TARGETS

1 Exact tasks table schema
2 Exact queued or pending status literal
3 Existing running/completed/failed hydration path
4 Existing telemetry object shape
5 Safe insertion point with zero reducer mutation

DECISION RULE

Only proceed to implementation if:
queued-state definition is explicit
and
existing hydration path is clearly identified

If either is unclear:
STOP
Do not wire metric
Do not guess
Do not broaden scope

EXPECTED OUTPUT ARTIFACT

/tmp/phase62b_tasks_queued_discovery.out

NEXT SAFE ACTION AFTER RUN

Review discovery output.
Then define one bounded implementation patch only.

END RUNBOOK
