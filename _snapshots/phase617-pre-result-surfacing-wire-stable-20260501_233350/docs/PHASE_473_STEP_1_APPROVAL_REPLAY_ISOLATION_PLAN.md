PHASE 473 — STEP 1
APPROVAL REPLAY + ISOLATION AUDIT PLAN

OBJECTIVE

Prove that approval APPROVE / REJECT outcomes remain isolated and replay-safe across repeated mixed deterministic execution order.

This step audits whether:

• repeated approval-APPROVED runs remain deterministic
• repeated approval-REJECTED runs remain deterministic
• approval-APPROVED artifacts do not mask later approval-REJECTED artifacts
• approval-REJECTED artifacts do not contaminate later approval-APPROVED artifacts
• execution blocking after approval rejection remains preserved
• replay produces identical approval decision artifacts

────────────────────────────────

MIXED APPROVAL RUN ORDER

Run 1:
governance APPROVED
approval APPROVED
echo hello world

Run 2:
governance APPROVED
approval REJECTED
echo reject hello world

Run 3:
governance APPROVED
approval APPROVED
echo hello mars

Run 4:
governance APPROVED
approval REJECTED
echo reject deterministic flow

────────────────────────────────

EXPECTED ISOLATION RULES

For approval-APPROVED runs:

• governance artifact must exist with decision = APPROVED
• approval artifact must exist with operatorApproval = true
• execution artifact must exist
• output must remain deterministic

For approval-REJECTED runs:

• governance artifact must exist with decision = APPROVED
• approval artifact must exist with operatorApproval = false
• approval failure artifact must exist
• execution artifact must be absent
• output must remain deterministic

────────────────────────────────

CROSS-RUN INVARIANTS

• earlier approval-APPROVED runs must not mask later approval-REJECTED runs
• earlier approval-REJECTED runs must not contaminate later approval-APPROVED runs
• execution artifacts must exist only for approval-APPROVED planIds
• approval failure artifacts must exist only for approval-REJECTED planIds
• governance artifacts must remain deterministic across both approval outcomes
• artifact filenames must remain deterministic per input
• mixed ordering must remain replay-safe

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• mixed approval approve/reject run order is defined
• isolation expectations are explicit
• cross-run approval invariants are explicit

