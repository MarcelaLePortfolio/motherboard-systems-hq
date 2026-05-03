#!/usr/bin/env bash
set -euo pipefail

OUT="PHASE62B_SUCCESS_RATE_LIVE_VALIDATION_RUNBOOK_20260317.md"

cat > "$OUT" << 'RUNBOOK'
PHASE 62B — SUCCESS RATE LIVE VALIDATION RUNBOOK
Date: 2026-03-17

OBJECTIVE

Capture bounded runtime proof that Success Rate now hydrates correctly on the live dashboard while preserving corridor discipline.

SCOPE

Validate only:

- Success Rate
- Running Tasks
- Latency
- single-writer safety
- no layout drift

DO NOT during this validation:

- edit layout
- change transport
- change reducer contracts
- broaden authority
- patch forward from ambiguous runtime behavior

PRECHECKS

Confirm before runtime validation:

1. Shared metrics success writer neutralized in source.
2. Telemetry bootstrap imported through dashboard bundle entry.
3. Dashboard bundle rebuilt after neutralization.
4. Bundle contains no direct success writer.
5. Success telemetry module remains authoritative writer.

OPERATOR STEPS

1. Start the dashboard in the normal protected local workflow.
2. Open /dashboard in the browser.
3. Record the initial values for:
   - Active Agents
   - Tasks Running
   - Success Rate
   - Latency
4. Trigger at least one terminal-success task event.
5. Observe whether Success Rate changes truthfully after the terminal-success event.
6. Trigger at least one terminal-failure task event.
7. Observe whether Success Rate changes truthfully after the terminal-failure event.
8. Confirm Running Tasks still increments/decrements correctly.
9. Confirm Latency still updates correctly.
10. Confirm there is no layout drift and no metric ownership anomaly.
11. Capture screenshots or notes externally if desired.

EXPECTED PASS BEHAVIOR

- Success Rate changes only after terminal task outcomes
- Running Tasks still behaves correctly
- Latency still behaves correctly
- no layout drift
- no second writer appears
- no bundle-side regression appears

FAIL CONDITIONS

Validation FAILS immediately if any of the following occurs:

- Success Rate never moves under terminal events
- Success Rate moves from the wrong corridor
- Running Tasks regresses
- Latency regresses
- layout drift appears
- bundle-side writer regression appears
- ownership becomes ambiguous again

DISCIPLINE RULE

If runtime validation fails, stop and record findings.
Do not patch forward from unclear runtime behavior.

RESULT TEMPLATE

Validation Result:
- success_terminal_event_observed:
- failure_terminal_event_observed:
- success_rate_moved:
- running_tasks_ok:
- latency_ok:
- layout_ok:
- bundle_writer_regression:
- ownership_regression:
- final_status:

NEXT ACTION RULE

Proceed to final acceptance only if final_status=PASS.
Otherwise record blocker findings and stop.
RUNBOOK

echo "Runbook written to $OUT"
