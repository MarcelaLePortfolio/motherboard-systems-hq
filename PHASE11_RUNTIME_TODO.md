# Phase 11 – Runtime TODO (No More Git Needed First)

You are at a clean, fully documented checkpoint.

From here, the actual **runtime** actions to perform (no edits required beforehand) are:

1. From repo root, with containers running:

   scripts/phase11_delegate_task_curl.sh

   - Note HTTP status
   - Note response body (look for any task identifier, e.g. taskId)
   - Note any relevant lines in printed docker-compose logs

2. After you know the correct task identifier, run:

   scripts/phase11_complete_task_curl.sh <TASK_ID>

   - Replace <TASK_ID> with the real value from step 1
   - Again, note HTTP status, response body, and logs

3. Based on results:

   - If both succeed:
     - Move on to Task Delegation UI validation in the containerized dashboard.

   - If either fails:
     - Start a new thread and say:
       “Continue Phase 11 from the point where the curl tests for /api/delegate-task or /api/complete-task failed. I have the curl output and logs.”
     - Bring:
       - The exact command(s) you ran
       - Full responses
       - Relevant docker-compose log snippets

