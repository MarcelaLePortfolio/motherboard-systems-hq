# Phase 11 – Ready for Container Rebuild & Stub Validation

You have:
- Stubbed /api/delegate-task and /api/complete-task in server.mjs
- Pushed changes to feature/v11-dashboard-bundle
- Multiple guides documenting what to do next

This file is the minimal, current-runtime reminder.

---

## ✅ Next Runtime Commands (In Order)

From repo root:

1) Rebuild and restart the container so it picks up the stubbed endpoints:

docker-compose build --no-cache
docker-compose down
docker-compose up -d

(Optional) Verify:

docker-compose logs -f --tail=50

Expect:
- dashboard-1 → Server running on http://0.0.0.0:3000
- postgres-1 → database system is ready to accept connections

2) Run the delegate-task curl helper:

scripts/phase11_delegate_task_curl.sh

Expect now:
- HTTP 200
- JSON with:
  - id: fakeId (timestamp-ish)
  - title, agent, notes (echoed back)
  - status: "delegated"
  - source: "stub"

3) Copy the id and run the complete-task helper:

scripts/phase11_complete_task_curl.sh <TASK_ID>

(Replace <TASK_ID> with the id from Step 2.)

Expect:
- HTTP 200
- JSON with:
  - id: <TASK_ID>
  - status: "completed"
  - source: "stub"

If both succeed with clean logs:
- Move on to Task Delegation UI validation in the containerized dashboard.

If either fails:
- Save the curl output + docker-compose logs and start from:
  “Continue Phase 11 from the point where the stubbed task endpoint curl tests failed. I have the curl output and logs.”
