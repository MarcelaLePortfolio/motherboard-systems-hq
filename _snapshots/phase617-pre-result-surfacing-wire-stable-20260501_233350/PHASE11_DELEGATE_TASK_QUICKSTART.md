# Phase 11 – Delegate Task Quickstart

Use this when you just want the next command without re-reading all the planning files.

---

## Next Runtime Command

From repo root, with containers running:

scripts/phase11_delegate_task_curl.sh

Then:

1. Note:
   - HTTP status
   - Response body (look for any task identifier, e.g. taskId)
   - Any relevant lines in printed docker-compose logs

2. Use the identifier with:

   scripts/phase11_complete_task_curl.sh <TASK_ID>

   (Replace <TASK_ID> with the real value.)

3. Based on results:
   - If both succeed → move on to Task Delegation UI validation in the containerized dashboard.
   - If either fails → start a new thread with the curl output + logs.
