PHASE 456 — RUN_VIEW REPAIR RETRY (CORRECT PATHS)

CLASSIFICATION:
CONTROLLED CANONICAL DB REPAIR

OBJECTIVE

Retry the missing run_view repair on the canonical restored stack using the
verified actual migration paths.

VERIFIED PATH CORRECTION

Incorrect attempted path:
migrations/drizzle_pg/...

Actual verified path:
drizzle_pg/0007_phase36_1_run_view.sql
drizzle_pg/0007_phase36_2_run_view_contract.sql

SAFETY

• No Docker reset
• No Docker prune
• No volume deletion
• No image deletion
• No source mutation
• No compose mutation
• Only the minimal run_view view repair is attempted

SUCCESS CONDITION

• public.run_view exists
• /api/runs returns successfully
• canonical dashboard remains healthy

