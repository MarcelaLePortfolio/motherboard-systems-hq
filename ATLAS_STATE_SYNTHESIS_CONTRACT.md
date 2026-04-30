Atlas Subsystem State Synthesis Contract

Objective:
Define Atlas as a strict state synthesis layer that transforms raw telemetry events into structured system understanding WITHOUT contaminating telemetry or execution layers.

──────────────────────────────

1. ROLE OF ATLAS
Atlas is a derived state engine.

It is responsible for:
- Interpreting raw event streams
- Producing system-level state understanding
- Tracking subsystem health trends over time

Atlas is NOT:
- A telemetry renderer
- A task lifecycle tracker
- A raw event storage system

──────────────────────────────

2. INPUTS (ALLOWED SOURCES)

Atlas may consume ONLY:

- Telemetry Console event stream (raw events)
  - worker claim events
  - execution start events
  - execution completion events
  - DB transition events
  - system log events

- Task lifecycle transitions (state-only, not logs)

──────────────────────────────

3. OUTPUTS (ALLOWED SURFACES)

Atlas may produce:

A. System State Summary
- stable | degraded | critical | unknown

B. Subsystem Health Signals
- worker health
- execution health
- database health
- API responsiveness

C. Trend Interpretation
- latency trend: rising | stable | improving
- throughput trend: increasing | decreasing | stable

D. Risk Flags
- execution risk detected
- retry saturation risk
- system instability warning

──────────────────────────────

4. STRICT PROHIBITIONS

Atlas MUST NOT:
- Render raw event logs
- Display chronological event history
- Recreate snapshot-based telemetry views
- Override or mutate event stream data
- Produce per-task lifecycle logs

──────────────────────────────

5. SEPARATION OF CONCERNS

Telemetry Console → WHAT HAPPENED
Task History → WHAT HAPPENED PER TASK
Atlas → WHAT IT MEANS
Worker System → WHAT CAUSED IT

──────────────────────────────

6. UI INTEGRATION RULES

Atlas outputs may appear in:
- System Health Dashboard
- High-level status panels
- Monitoring summaries

Atlas outputs MUST NOT appear in:
- Telemetry Console
- Task History views
- Raw execution logs

──────────────────────────────

7. DESIGN PRINCIPLE

Raw truth and interpreted meaning must never coexist in the same rendering layer.

──────────────────────────────

STATUS:
Phase: Atlas Boundary Definition
Scope: System Interpretation Layer
Backend: No changes
