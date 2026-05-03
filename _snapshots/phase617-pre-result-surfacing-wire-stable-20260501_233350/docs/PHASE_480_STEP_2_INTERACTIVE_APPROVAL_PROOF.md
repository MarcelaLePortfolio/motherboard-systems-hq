PHASE 480 STEP 2 — INTERACTIVE APPROVAL PROOF
=============================================

OBJECTIVE

Prove that the deterministic operator-controlled approval input works as intended.

This proof verifies:

• APPROVE input permits execution
• REJECT input blocks execution
• approval artifacts are deterministic
• approval failure artifacts are deterministic
• replay remains stable for the same input + decision pair

────────────────────────────────

TEST CASES

CASE 1 — APPROVE

Input:
echo hello world

Approval input:
APPROVE

Expected:

• approval artifact present with operatorApproval = true
• execution artifact present
• output = EXECUTION_OK: echo hello world

────────────────────────────────

CASE 2 — REJECT

Input:
echo hello world

Approval input:
REJECT

Expected:

• approval artifact present with operatorApproval = false
• approval failure artifact present
• execution artifact absent
• output = APPROVAL_REJECTED

────────────────────────────────

INVARIANTS

• same request + APPROVE → same approval + execution artifacts
• same request + REJECT → same approval + approval-failure artifacts
• REJECT must block execution deterministically
• operator-controlled decision must override prior pattern-based approval logic
• replay must reproduce identical artifacts for same request + decision

────────────────────────────────

SUCCESS CRITERIA

Step 2 is complete when:

• APPROVE path is observed
• REJECT path is observed
• downstream execution blocking is proven for REJECT
• artifacts remain deterministic and replay-safe

