# Phase 11 – Run This Now

All planning files are complete.
All stubs are inserted.
All scripts are created.
Repo is clean.
Containers must now be rebuilt so server.mjs updates take effect.

This file exists ONLY to tell you the exact next command.

---

## ▶️ Next Runtime Command (Run This First)

scripts/phase11_rebuild_dashboard_container.sh

This will:
- Rebuild the dashboard container with no cache
- Restart containers
- Show logs so you can confirm the server booted successfully

---

## ▶️ Then Run

scripts/phase11_delegate_task_curl.sh

Expect:
- HTTP 200
- JSON with:
  - id: <fakeId>
  - status: "delegated"
  - source: "stub"

Copy the returned id.

---

## ▶️ Then Run

scripts/phase11_complete_task_curl.sh <TASK_ID>

Replace <TASK_ID> with the id from the previous step.

Expect:
- HTTP 200
- JSON:
  {
    "id": <TASK_ID>,
    "status": "completed",
    "source": "stub"
  }

---

If both succeed with clean logs → Move to Task Delegation UI validation.

If either fails → Start a new thread with:

“Continue Phase 11 from the point where the stubbed task endpoint curl tests failed. I have the script output and logs.”
