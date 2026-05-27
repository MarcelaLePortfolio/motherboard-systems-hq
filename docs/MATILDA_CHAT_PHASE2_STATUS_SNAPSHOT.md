Matilda Chat Phase 2 – Status Snapshot (SSE + Layout)

As of commit 87d90046 on branch feature/v11-dashboard-bundle:

- Matilda Chat Console is injected above Task Delegation and fully styled.
- Project Visual Output card is injected below Atlas Subsystem Status.
- A JS-driven two-column layout aligns:
  - Row 1: Matilda Chat (left) with Task Delegation (right)
  - Row 2: Project Visual Output (left) with System Reflections (right)
- Critical Ops Alerts and related right-column cards share a consistent width rail.

SSE stream helpers:

- scripts/start-sse-streams.sh
  - Starts:
    - reflections-stream/reflections_stream.py
    - ops-stream/ops_stream.py

- ecosystem.sse-streams.config.cjs
  - PM2 ecosystem file for the same two Python SSE processes.

Recommended bring-up sequence from a cold start:

1) Start Node dashboard:
   NODE_ENV=development PORT=3000 node server.mjs &

2) Start SSE streams:
   ./scripts/start-sse-streams.sh

3) Open the dashboard:
   http://127.0.0.1:3000

Expected visible result:

- Agent badges show live states (not "unknown").
- System Reflections and Critical Ops Alerts begin streaming.
- Matilda Chat + Task Delegation, and Project Visual Output + System Reflections,
  appear in a coherent two-column layout.
