PHASE 473 — STEP 2
APPROVAL REPLAY + ISOLATION AUDIT PROOF

OBJECTIVE

Verify that mixed approval APPROVE / REJECT execution order preserved deterministic artifact isolation.

This proof confirms:

• approval-APPROVED artifacts remain present after later approval-REJECTED runs
• approval-REJECTED artifacts remain explicit without contaminating approval-APPROVED runs
• execution artifacts exist only for approval-APPROVED planIds
• approval failure artifacts exist only for approval-REJECTED planIds
• governance artifacts remain deterministic across both approval outcomes
• mixed approval ordering remains replay-safe

────────────────────────────────

MIXED RUN ORDER EXECUTED

Run 1:
approval APPROVED
echo hello world

Run 2:
approval REJECTED
echo reject hello world

Run 3:
approval APPROVED
echo hello mars

Run 4:
approval REJECTED
echo reject deterministic flow

────────────────────────────────

AUDIT EXPECTATIONS

APPROVED artifacts must exist for:

• echo hello world
• echo hello mars

APPROVAL-REJECTED artifacts must exist for:

• echo reject hello world
• echo reject deterministic flow

Execution must be blocked for approval-REJECTED planIds.

────────────────────────────────

SUCCESS CRITERIA

Step 2 is complete when:

• approval-APPROVED artifacts are confirmed present
• approval-REJECTED artifacts are confirmed present
• blocked execution artifacts are confirmed absent for approval-REJECTED planIds
• deterministic approval isolation is confirmed across mixed run order

