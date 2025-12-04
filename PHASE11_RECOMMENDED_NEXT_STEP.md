# Phase 11 – Recommended Next Step From Container Baseline

## Where You Are
- Repo: Motherboard_Systems_HQ
- Branch: feature/v11-dashboard-bundle
- Container: rebuilt, restarted, and healthy
- Dashboard backend (server.mjs) running inside container on port 3000
- Matilda Chat Console: working
- Reflections SSE: deferred
- Bundling: deferred

You are at the decision point for how to validate Task Delegation.

---

## Recommended Path (In Order)

### 1️⃣ Start With Backend Curl Tests (Container API First)

Reason:
- Isolates backend behavior from frontend/UX.
- Keeps changes minimal and fully observable.
- Perfectly aligned with your “one fix at a time” Phase 11 rules.

**Step 1 – Delegate Task via curl**

From the host (while the container is running), send a test task:

curl -i -X POST http://127.0.0.1:3000/api/delegate-task \
  -H "Content-Type: application/json" \
  -d '{"title":"Phase 11 container curl test","agent":"cade","notes":"Created via Phase 11 backend validation"}'

Check:
- HTTP status (200 or expected success).
- Response body shape (id/status/etc.).
- docker-compose logs -f --tail=50 for server.mjs errors.

**Step 2 – Complete Task via curl**

Once you know how tasks are identified (for example, by taskId), test completion:

curl -i -X POST http://127.0.0.1:3000/api/complete-task \
  -H "Content-Type: application/json" \
  -d '{"taskId":123}'

(Replace 123 with a real ID or whatever identifier your API expects.)

Check again:
- HTTP status.
- Response body.
- Logs for errors.

If either endpoint fails:
- Stop here.
- Capture:
  - Curl command and full response.
  - Relevant log lines from the dashboard container.
- The next thread will focus on a small, targeted patch to server.mjs or related code.

---

### 2️⃣ Then Validate Task Delegation UX in the Dashboard

Only after both curl tests are reasonably healthy:

1. Open the container-backed dashboard in your browser.
2. Use the Task Delegation card to:
   - Create a test task.
   - If possible, complete a task from the UI.
3. In browser dev tools:
   - Network tab:
     - Confirm /api/delegate-task and /api/complete-task calls.
     - Check status codes and payloads.
   - Console tab:
     - Note any unhandled JS errors.

If the backend looks fine but the UI feels broken or confusing:
- Log:
  - What you clicked/typed.
  - What you expected.
  - What actually happened.
- The next code changes should target frontend behavior only, still avoiding bundling.

---

### 3️⃣ Only After That – Atlas Status & Bundling

Once the following are true:
- /api/delegate-task and /api/complete-task work from curl.
- Task Delegation UI behaves cleanly enough for Phase 11.

Then you can:
1. Do a light Atlas status confirmation (no new complex behavior).
2. Revisit bundling (JS/CSS), followed by:
   - Re-testing Matilda Chat.
   - Re-testing Task Delegation.
   - Re-confirming Atlas status.

---

## TL;DR Recommendation

Recommended next move right now:
- Run backend curl tests against /api/delegate-task and /api/complete-task from the host.
- Use the results to decide whether the next thread focuses on:
  - A small server.mjs patch (if curl fails), or
  - Dashboard UX-only refinements (if curl passes but UI is awkward).

When starting the next thread, you can say:

“Continue Phase 11 from the point where the container was rebuilt and I’m about to run curl tests for /api/delegate-task and /api/complete-task.”
