
# Phase 717 — Next Corridor

Authoritative stable state:

- Recent Tasks preserved

- Task History preserved

- Execution Inspector removed

- Recent Logs shell removed

- Telemetry Console preserved

- Runtime healthy

- Stable checkpoint tag:

  phase717-stable-telemetry-console

Corridor classification:

SAFE UI POLISH / LIFECYCLE CONSOLIDATION ONLY

Approved next actions:

1. Improve Recent Tasks visual hierarchy only.

2. Tighten spacing/padding inside Recent Tasks.

3. Improve retry/requeue affordance placement inside task cards.

4. Preserve all current telemetry container wrappers.

5. Avoid removing additional tabs/panels until dependency mapping is completed.

6. Keep rollback corridor anchored to:

   phase717-stable-telemetry-console

Explicitly prohibited:

- Broad telemetry container removal

- Multi-surface deletion passes

- CSS-wide speculative cleanup

- Removing Task History without isolated dependency validation

- Touching execution contracts or SSE routing

