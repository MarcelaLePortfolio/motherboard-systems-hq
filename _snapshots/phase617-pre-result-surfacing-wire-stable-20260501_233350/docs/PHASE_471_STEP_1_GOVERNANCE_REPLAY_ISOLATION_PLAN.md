PHASE 471 — STEP 1
GOVERNANCE REPLAY + ISOLATION AUDIT PLAN

OBJECTIVE

Prove that governance APPROVE / REJECT outcomes remain isolated and replay-safe across repeated mixed execution order.

This step audits whether:

• repeated APPROVED runs remain deterministic
• repeated REJECTED runs remain deterministic
• APPROVED artifacts do not mask later REJECTED artifacts
• REJECTED artifacts do not contaminate later APPROVED artifacts
• downstream blocking after rejection remains preserved
• replay produces identical governance decision artifacts

────────────────────────────────

MIXED GOVERNANCE RUN ORDER

Run 1:
supported valid input
echo hello world

Expected:
APPROVED

Run 2:
unsupported valid input
say hello world

Expected:
REJECTED

Run 3:
supported valid input
echo hello mars

Expected:
APPROVED

Run 4:
unsupported valid input
say deterministic flow

Expected:
REJECTED

────────────────────────────────

EXPECTED ISOLATION RULES

For APPROVED runs:

• governance artifact must exist with decision = APPROVED
• approval artifact must exist
• execution artifact must exist
• output must remain deterministic

For REJECTED runs:

• governance artifact must exist with decision = REJECTED
• governance failure artifact must exist
• approval artifact must be absent
• execution artifact must be absent
• output must remain deterministic

────────────────────────────────

CROSS-RUN INVARIANTS

• earlier APPROVED runs must not mask later REJECTED runs
• earlier REJECTED runs must not contaminate later APPROVED runs
• approval artifacts must only exist for APPROVED planIds
• execution artifacts must only exist for APPROVED planIds
• governance failure artifacts must only exist for REJECTED planIds
• artifact filenames must remain deterministic per input
• mixed ordering must remain replay-safe

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• mixed approve/reject run order is defined
• isolation expectations are explicit
• cross-run governance invariants are explicit

