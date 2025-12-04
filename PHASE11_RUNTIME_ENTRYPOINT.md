# Phase 11 – Runtime Entry Point (Use the Scripts, Not More Docs)

From this point forward, when you come back and just want to *do the thing*:

---

## ▶️ Single Runtime Path

From repo root:

1) Rebuild & restart the dashboard container so stubbed endpoints are live:

scripts/phase11_rebuild_dashboard_container.sh

This will:
- docker-compose build --no-cache
- docker-compose down
- docker-compose up -d
- Show the last 50 lines of logs

---

2) Run the delegate-task curl helper:

scripts/phase11_delegate_task_curl.sh

Expected:
- HTTP 200
- JSON with:
  - id: fakeId (timestamp-ish)
  - title: "Phase 11 container curl test"
  - agent: "cade"
  - notes: "Created via Phase 11 backend validation"
  - status: "delegated"
  - source: "stub"

Copy the id field.

---

3) Run the complete-task curl helper:

scripts/phase11_complete_task_curl.sh <TASK_ID>

Replace <TASK_ID> with the id from Step 2.

Expected:
- HTTP 200
- JSON with:
  - id: <TASK_ID>
  - status: "completed"
  - source: "stub"

---

## ✅ If Both Succeed

Next focus:
- Task Delegation UI validation in the containerized dashboard.

## ❌ If Either Fails

Bring into a new thread:
- The exact script you ran
- Full output (including headers/body from curl)
- Relevant docker-compose logs

Start from:

“Continue Phase 11 from the point where the stubbed task endpoint curl tests failed. I have the script output and logs.”
