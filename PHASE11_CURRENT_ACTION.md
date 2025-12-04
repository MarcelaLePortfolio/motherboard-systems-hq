# Phase 11 – Current Action Checklist (Right Now)

Baseline:
- Repo: Motherboard_Systems_HQ
- Branch: feature/v11-dashboard-bundle
- Container: dashboard + Postgres running and healthy
- Helper scripts added:
  - scripts/phase11_delegate_task_curl.sh
  - scripts/phase11_complete_task_curl.sh

You are ready to actually run the backend tests.

---

## ✅ Step 1 – Delegate Task Curl Test

From repo root:

scripts/phase11_delegate_task_curl.sh

Capture:
- HTTP status from curl
- Response body (look for any task identifier)
- Any relevant lines from `docker-compose logs --tail=50`

Use the response to determine the correct task identifier (for example `taskId`).

---

## ✅ Step 2 – Complete Task Curl Test

Once you have the ID (replace `123` with the real value):

scripts/phase11_complete_task_curl.sh 123

Capture again:
- HTTP status from curl
- Response body
- Any relevant lines from `docker-compose logs --tail=50`

---

## ➡️ After Both Steps

- If both calls are healthy:
  - Move on to Task Delegation UI validation in the containerized dashboard.

- If either call fails:
  - Bring the curl output + log snippets into a new thread and start from:
    “Continue Phase 11 from the point where the curl tests for /api/delegate-task or /api/complete-task failed.”

