# Phase 11 – Task Delegation Backend Curl Tests (Container API)

This file captures the exact curl commands and expectations for validating
`/api/delegate-task` and `api/complete-task` against the containerized backend.

## Prerequisite

- Containerized dashboard is running and healthy:
  - `docker-compose up -d`
  - Logs show: `Server running on http://0.0.0.0:3000`

---

## 1️⃣ Test /api/delegate-task (Create Task)

From the host, run:

curl -i -X POST http://127.0.0.1:3000/api/delegate-task \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Phase 11 container curl test",
    "agent": "cade",
    "notes": "Created via Phase 11 backend validation"
  }'

### What to Check

- HTTP status = 200 (or expected success)
- Response includes created task data (ID or details)
- `docker-compose logs -f --tail=50` shows no errors

If this fails:
- Capture the entire curl output (headers + body)
- Capture any log lines from dashboard-1
- Stop here and fix backend first

---

## 2️⃣ Test /api/complete-task (Complete Task)

Once you know the task identifier returned in Step 1, run:

curl -i -X POST http://127.0.0.1:3000/api/complete-task \
  -H "Content-Type: application/json" \
  -d '{
    "taskId": 123
  }'

(Replace `123` with the real ID.)

### What to Check

- HTTP status = 200
- Response confirms completion
- No container errors in logs

If this fails:
- Capture the failing curl output
- Capture relevant dashboard-1 log lines
- Fix backend before touching frontend

---

## 3️⃣ Interpreting Results

### A. Both endpoints succeed
Proceed to Dashboard Task Delegation UX validation.

### B. Any endpoint fails
Start a new thread:

“Continue Phase 11 from the point where curl tests failed. I have the curl output and logs.”

Attach:
- The curl command
- The response
- The log snippet

---

## 4️⃣ How to Resume Later

In a new thread, say:

“Start from PHASE11_TASK_DELEGATION_CURL_TESTS — I’m ready to run backend curl tests.”

