# Phase 11 – Next Actions After Functional Behavior Baseline

Context:
- Repo: Motherboard_Systems_HQ
- Branch: feature/v11-dashboard-bundle
- Baseline: server.mjs is the active backend, Matilda Chat Console is functional, dashboard layout is stable, Reflections SSE is explicitly deferred.

This file defines the recommended next actions from the current baseline so future threads can resume without re-deriving priorities.

---

## 1️⃣ Immediate Focus – Task Delegation UX Validation

Goal:
- Confirm that the Task Delegation card behaves cleanly end-to-end for both:
  - Creating tasks via `/api/delegate-task`
  - Marking tasks complete via `/api/complete-task`

### A. Backend Sanity Checks

1. Start the backend:

   - From the project root:
     - `node server.mjs`

2. Verify delegate-task via curl:

   - Example (adjust JSON to match current route expectations):

     - `curl -i -X POST http://127.0.0.1:3000/api/delegate-task \`
       `  -H "Content-Type: application/json" \`
       `  -d '{"title":"Test task from Phase 11 plan","agent":"cade","notes":"Created via Phase 11 UX validation"}'`

   - Confirm:
     - HTTP 200 (or expected success code)
     - Response body includes some kind of success indicator (id, status, etc.).
     - No unhandled exceptions in the server.mjs console.

3. Verify complete-task via curl:

   - Once you know a valid task id from your system (or whatever key the API expects), test:

     - `curl -i -X POST http://127.0.0.1:3000/api/complete-task \`
       `  -H "Content-Type: application/json" \`
       `  -d '{"taskId":123}'`

   - Confirm:
     - HTTP 200 (or expected success code).
     - Response indicates completion.
     - No server errors.

4. If errors appear:
   - Note:
     - Exact error message.
     - Stack trace snippet (if any).
     - Whether the error is schema-related (missing fields) or logic-related.
   - Next action in that case:
     - Patch server.mjs in a focused way (one fix at a time, respecting Phase 11 debugging discipline).

### B. Frontend UX Checks (Dashboard)

With `node server.mjs` running:

1. Open the dashboard in the browser (same URL as used during Matilda Chat testing).

2. Task Delegation Card:
   - Enter a task title + description and submit.
   - Confirm:
     - No JS console errors.
     - UI shows a “delegated” confirmation (whatever the current behavior is).
     - If a task list or activity view exists, ensure it updates appropriately.

3. Task Completion:
   - Using whatever UI exists (checkbox, button, etc.), complete a task.
   - Confirm:
     - UX is consistent and does not feel “stuck”.
     - The UI and backend behavior match (e.g., tasks disappear, status changes).

4. If UX feels confusing or stuck:
   - Log:
     - What you clicked or typed.
     - What you expected to see.
     - What actually happened.
   - These notes will drive the next modifications in a future thread.

---

## 2️⃣ Atlas Status Behavior – Clarify and Confirm

Goal:
- Decide whether the Atlas status card should remain a placeholder for Phase 11 or receive a minimal live hook.

### Recommended Minimal Plan

1. Keep Atlas behavior simple for now:
   - Confirm that Atlas status is driven by a known backend source (e.g., `/api/agents` or a direct field in `/api/metrics`).
   - Ensure:
     - No JS console errors tied to Atlas.
     - If backend returns data, the component handles both “Atlas present” and “Atlas unavailable” gracefully.

2. If Atlas is already wired to `/api/agents`:
   - Confirm that the endpoint:
     - Returns a consistent shape for Atlas.
     - Does not break if Atlas is offline or missing.
   - If needed, add a simple default (`status: "offline"` or similar) rather than adding new complex logic.

3. Defer any “Atlas rich behavior” (e.g., heartbeat animations, detailed runtime stats) to a later phase.
   - Phase 11 only requires a stable, non-crashy status indication.

---

## 3️⃣ Reflections Behavior – Keep Deferred but Document Options

The baseline explicitly defers Reflections SSE for this phase.

Do not implement anything in this section yet; just keep the decision space documented for a future pass:

- Option A: Fix SSE path (port 3101) and ensure:
  - Host and browser can connect with EventSource.
  - PM2 process `reflection-sse-server` is actually listening on the expected port.
- Option B: Replace SSE with simple HTTP polling from the reflections store (e.g., Postgres/SQLite) for simplicity and robustness.

When Phase 11’s required goals (Matilda + Task Delegation + Atlas stability) are fully satisfied, we can revisit this decision.

---

## 4️⃣ Bundling Pass – Final Phase 11 Clean-Up

Bundling (e.g., `bundle-core.js`) is explicitly a “later” step to avoid destabilizing the working dashboard.

When ready:

1. Confirm:
   - Dashboard is fully functional with the current script tag setup.
   - No open functional bugs remain for Matilda Chat, Task Delegation, or Atlas status.

2. Only then:
   - Revisit JS/CSS bundling.
   - Replace multiple `<script>` tags with a single bundle.
   - Re-run all functional checks:
     - Matilda Chat
     - Task Delegation flows
     - Atlas status
     - Metrics tiles (as far as backend data allows)

3. Tag a new stable baseline after bundling:
   - Example: `v11.2-dashboard-bundled-stable` or similar.

---

## 5️⃣ How to Resume in a Future Thread

In a new ChatGPT session, after uploading project context, you can say:

- “Continue Phase 11 – validate Task Delegation UX from the PHASE11_NEXT_ACTIONS_AFTER_FUNCTIONAL_BEHAVIOR plan.”
- or:
- “Pick up Phase 11 by testing /api/delegate-task and /api/complete-task and then revisiting Atlas status behavior.”

This file establishes Task Delegation UX validation as the immediate next action, keeps Atlas simple, and defers Reflections and bundling until core functional behavior is fully validated.
