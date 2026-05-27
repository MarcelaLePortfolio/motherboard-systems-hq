# Phase 11 – Task Delegation Curl Run Sequence (Container)

Use this file as the concrete “do this now” sequence for Task Delegation backend validation.

Baseline:
- Repo: Motherboard_Systems_HQ
- Branch: feature/v11-dashboard-bundle
- Container: dashboard + Postgres running and healthy

---

## 1️⃣ Verify Containers Are Up

If needed, run:

docker-compose up -d
docker-compose logs -f --tail=50

You should see something like:

- dashboard-1  | Server running on http://0.0.0.0:3000
- postgres-1   | database system is ready to accept connections

---

## 2️⃣ Run Delegate Task Curl Test

From the host (with containers running), run:

curl -i -X POST http://127.0.0.1:3000/api/delegate-task \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phase 11 container curl test",
    "agent": "cade",
    "notes": "Created via Phase 11 backend validation"
  }'

Then, in a second terminal:

docker-compose logs -f --tail=50

Capture:
- HTTP status from curl (aiming for 200 or expected success)
- Response body (look for any task identifier or status)
- Any errors or stack traces in dashboard-1 logs

If this fails:
- Stop and save:
  - Full curl output (headers + body)
  - Relevant dashboard-1 log lines

---

## 3️⃣ Run Complete Task Curl Test (After You Have an ID)

Once you know the correct identifier from Step 2 (for example, taskId), run:

curl -i -X POST http://127.0.0.1:3000/api/complete-task \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 123
  }'

Replace 123 with the real ID (or whatever identifier your API expects).

Again, check:

docker-compose logs -f --tail=50

Capture:
- HTTP status
- Response body
- Any errors or stack traces in dashboard-1 logs

If this fails:
- Stop and save:
  - Full curl output
  - Relevant dashboard-1 log lines

---

## 4️⃣ What To Do With Results

If both curl tests succeed:

- Next step: validate Task Delegation UI behavior in the containerized dashboard:
  - Use Task Delegation card to create a test task.
  - Complete a task if possible from the UI.
  - Watch browser Network + Console tabs for any issues.

If either curl test fails:

- In your next thread, say:

  "Continue Phase 11 from the point where the curl tests for /api/delegate-task or /api/complete-task failed. I have the curl output and logs."

- Have ready:
  - The exact curl command(s)
  - Full responses
  - Relevant docker-compose logs -f --tail=50 snippets

We will then:
- Apply a small, focused patch to server.mjs (or related files).
- Re-run the same curl tests to confirm the fix before touching UI or bundling.

---

## 5️⃣ How to Resume Later

In a fresh ChatGPT thread, you can say:

"Start from PHASE11_TASK_DELEGATION_RUN_SEQUENCE — I’m ready to run the backend curl tests against /api/delegate-task and /api/complete-task."

