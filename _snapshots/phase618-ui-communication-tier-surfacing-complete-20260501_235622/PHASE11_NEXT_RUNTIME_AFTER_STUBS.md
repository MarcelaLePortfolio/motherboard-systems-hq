# Phase 11 – Next Runtime Actions After Stubbing Task Endpoints

Use this when resuming from the point where stubbed /api/delegate-task and /api/complete-task
have been added and pushed.

---

## 1️⃣ Rebuild & Restart Container

From repo root:

docker-compose build --no-cache
docker-compose down
docker-compose up -d

Then verify:

docker-compose logs -f --tail=50

You should see:
- dashboard-1 → Server running on http://0.0.0.0:3000
- postgres-1 → database system is ready to accept connections

---

## 2️⃣ Run Delegate Task Curl Helper

scripts/phase11_delegate_task_curl.sh

Expected (HTTP 200):

{
  "id": <fakeId>,
  "title": "Phase 11 container curl test",
  "agent": "cade",
  "notes": "Created via Phase 11 backend validation",
  "status": "delegated",
  "source": "stub"
}

If this looks good, copy the `id` field.

---

## 3️⃣ Run Complete Task Curl Helper

scripts/phase11_complete_task_curl.sh <TASK_ID>

Replace <TASK_ID> with the id from Step 2.

Expected (HTTP 200):

{
  "id": <TASK_ID>,
  "status": "completed",
  "source": "stub"
}

Logs for both steps should show no new errors.

---

## 4️⃣ If Both Succeed

You are clear to move on to:
- Task Delegation UI validation in the containerized dashboard.

## 5️⃣ If Either Fails

Collect:
- The exact command you ran
- Full curl output (headers + body)
- Relevant docker-compose logs

Then say:

“Continue Phase 11 from the point where the stubbed task endpoint curl tests failed. I have the curl output and logs.”
