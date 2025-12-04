# Phase 11 – Runtime Next Steps After Stubbing Task Endpoints

To pick up from here, with stubbed /api/delegate-task and /api/complete-task in place:

## 1️⃣ Rebuild & Restart Container

From repo root:

docker-compose build --no-cache
docker-compose down
docker-compose up -d

(Optional) Verify:

docker-compose logs -f --tail=50

You should see:
- dashboard-1 → Server running on http://0.0.0.0:3000
- postgres-1 → database system is ready to accept connections

## 2️⃣ Run Delegate Task Curl Helper

scripts/phase11_delegate_task_curl.sh

Expected now:
- HTTP 200
- JSON with:
  - id: fakeId (timestamp-ish)
  - title, agent, notes (echoed)
  - status: "delegated"
  - source: "stub"

If this looks good, copy the `id` field.

## 3️⃣ Run Complete Task Curl Helper

scripts/phase11_complete_task_curl.sh <TASK_ID>

Replace <TASK_ID> with the id from the previous step.

Expected:
- HTTP 200
- JSON with:
  - id: <TASK_ID>
  - status: "completed"
  - source: "stub"

If both succeed with no errors in logs, you’re clear to move on to:
- Task Delegation UI validation in the containerized dashboard.

