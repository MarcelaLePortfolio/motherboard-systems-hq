PHASE 456 — RUN_VIEW REPAIR PLAN

CLASSIFICATION:
CONTROLLED CANONICAL DB REPAIR

OBJECTIVE

Repair the missing public.run_view relation on the canonical restored stack
without changing application code, compose definitions, or Docker state.

EVIDENCE BASIS

Prior evidence established:

• Canonical compose stack is healthy
• Dashboard is serving on localhost:8080
• Canonical postgres is up
• /api/runs triggers relation "run_view" does not exist
• Expected run_view migration files exist in repository history

REPAIR METHOD

1. Verify canonical stack
2. Verify run_view migration files exist in repo and dashboard container
3. Check whether run_view already exists
4. If missing, apply only:
   • 0007_phase36_1_run_view.sql
   • 0007_phase36_2_run_view_contract.sql
5. Re-verify run_view existence
6. Verify /api/runs and dashboard logs

NON-GOALS

• No Docker reset
• No Docker prune
• No volume deletion
• No image deletion
• No source mutation
• No compose mutation
• No broader bootstrap execution unless required later

SAFETY

This is the smallest database repair supported by the current evidence.
