Telemetry Console Event Stream Enforcement (Step 4)

Objective:
Convert Telemetry Console into a strict append-only event stream renderer and remove all non-event abstractions.

──────────────────────────────

IMPLEMENTATION TARGET

TelemetryConsole Component (Frontend)

──────────────────────────────

CHANGES TO APPLY

1. REMOVE
- Any system metric summaries
- Any task grouping or aggregation panels
- Any “status cards” derived from computed state
- Any UI that collapses multiple events into snapshots

──────────────────────────────

2. KEEP ONLY (STRICT EVENT STREAM)
- timestamped events (ordered chronologically)
- worker lifecycle events:
  - claim
  - execution start
  - execution completion
- database transition events
- system log events (raw only)

──────────────────────────────

3. RENDERING RULE
- One event = one row
- No grouping
- No summarization
- No inferred state
- No derived metrics

──────────────────────────────

4. DATA CONTRACT
Telemetry Console must consume ONLY:
- raw event stream source
- no computed selectors
- no merged telemetry views

──────────────────────────────

5. VALIDATION REQUIREMENT
After patch:
- UI is strictly chronological
- No snapshots exist in console
- No system/task metric overlap is visible
- Event stream is immutable in presentation layer

──────────────────────────────

STATUS
Phase: UI Enforcement Pass 4
Scope: Event Stream Normalization
Backend: No changes
