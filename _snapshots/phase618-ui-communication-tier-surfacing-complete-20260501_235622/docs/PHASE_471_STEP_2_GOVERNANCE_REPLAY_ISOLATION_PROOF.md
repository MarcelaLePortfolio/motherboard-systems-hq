PHASE 471 — STEP 2
GOVERNANCE REPLAY + ISOLATION AUDIT PROOF

OBJECTIVE

Verify that mixed governance APPROVE / REJECT execution order preserved deterministic artifact isolation.

This proof confirms:

• APPROVED governance artifacts remain present after later REJECTED runs
• REJECTED governance artifacts remain explicit without contaminating APPROVED runs
• approval artifacts exist only for APPROVED planIds
• execution artifacts exist only for APPROVED planIds
• governance failure artifacts exist only for REJECTED planIds
• mixed governance ordering remains replay-safe

────────────────────────────────

MIXED RUN ORDER EXECUTED

Run 1:
APPROVED
echo hello world

Run 2:
REJECTED
say hello world

Run 3:
APPROVED
echo hello mars

Run 4:
REJECTED
say deterministic flow

────────────────────────────────

AUDIT EXPECTATIONS

APPROVED artifacts must exist for:

• echo hello world
• echo hello mars

REJECTED artifacts must exist for:

• say hello world
• say deterministic flow

APPROVAL + EXECUTION must be blocked for REJECTED planIds.

────────────────────────────────

SUCCESS CRITERIA

Step 2 is complete when:

• APPROVED artifacts are confirmed present
• REJECTED artifacts are confirmed present
• blocked downstream artifacts are confirmed absent for REJECTED planIds
• deterministic governance isolation is confirmed across mixed run order

