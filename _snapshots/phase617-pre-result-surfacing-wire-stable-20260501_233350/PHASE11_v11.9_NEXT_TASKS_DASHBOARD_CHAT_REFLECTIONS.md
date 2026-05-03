
# Phase 11 – v11.9 Next Tasks: Dashboard Reliability · Matilda Chat UX · Reflections Backend Prep

## Context

* Branch: feature/v11-dashboard-bundle
* Handoffs: PHASE11_v11.8_POST_STUB_HANDOFF.md, PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md
* Current: sse-reflections-shim.js neutralizes `/events/reflections` EventSource until backend is ready.

## Task Group A – Dashboard Reliability (Next 3)

1. [ ] Run containerized dashboard and confirm no SSE errors in browser console (OPS online, Reflections shim silent).

   * Command: docker-compose up --build -d
   * URL: [http://127.0.0.1:8080/dashboard](http://127.0.0.1:8080/dashboard)
2. [ ] Hard-refresh dashboard 3–5x to verify:

   * No duplicate SSE connections.
   * OPS pill updates consistently.
3. [ ] Capture notes in PHASE11_v11.8_POST_STUB_HANDOFF.md under "Dashboard Reliability – v11.9" once verified.

## Task Group B – Matilda Chat UX (Next 3)

1. [ ] From dashboard, send a Matilda chat message and confirm:

   * Request hits `/api/chat` with agent `"matilda"`.
   * Response renders in Matilda Chat Console output region.
2. [ ] Verify Enter key submits chat and input is cleared + refocused.
3. [ ] If any failure is observed, log a bug note in PHASE11_v11.8_POST_STUB_HANDOFF.md under "Matilda Chat – v11.9 Findings".

## Task Group C – Reflections Backend Preparation (Next 3)

1. [ ] Re-read PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md and add a short "v11.9 Plan" section describing:

   * When to remove the shim.
   * Which port/endpoint the real Reflections SSE server will expose.
2. [ ] Locate existing Reflections SSE server source (e.g., reflection-sse-server.ts or similar) and note its current status in the same file.
3. [ ] Define a minimal "Phase 11.10" activation checklist in PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md (what must be true before swapping shim → real EventSource).

## Quick Command Sequences (v11.9)

### A. Dashboard Reliability – Container Checks

```bash
cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# Rebuild and start containers cleanly
docker-compose down
docker-compose up --build -d

# Optional: tail logs for dashboard / backend
docker-compose logs -f dashboard
```

Then:

* Open [http://127.0.0.1:8080/dashboard](http://127.0.0.1:8080/dashboard)
* Hard-refresh several times
* Watch browser console for SSE errors (OPS ok, Reflections shim quiet).

### B. Matilda Chat UX – API Sanity Check

With containers running:

```bash
cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

curl -i -X POST http://127.0.0.1:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Phase 11 v11.9 Matilda chat ping",
    "agent": "matilda"
  }'
```

Confirm:

* HTTP 200
* JSON body with Matilda response text (no server error).

Then test via dashboard UI:

* Type a short message.
* Press Enter.
* Confirm output appears in Matilda Chat Console and input clears.

### C. Reflections Backend Prep – Source Discovery

```bash
cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

# List reflections-related files at repo root
ls reflections* reflection* 2>/dev/null || true

# Search for Reflections SSE server definitions/usages
rg "Reflections" .
rg "events/reflections" .
rg "reflections-sse" .
```

Use these results while updating PHASE11_REFLECTIONS_SSE_SHIM_STATUS.md:

* Note actual SSE server file name.
* Note current port/endpoint assumptions.
* Draft "Phase 11.10 – Activation Checklist".

## How to Resume in a New Thread

Say: “Continue Phase 11 from v11.9 next tasks file PHASE11_v11.9_NEXT_TASKS_DASHBOARD_CHAT_REFLECTIONS.md.”
