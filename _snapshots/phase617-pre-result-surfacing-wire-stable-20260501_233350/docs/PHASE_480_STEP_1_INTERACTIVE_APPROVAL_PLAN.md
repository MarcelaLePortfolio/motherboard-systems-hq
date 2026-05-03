PHASE 480 STEP 1 — INTERACTIVE APPROVAL SURFACE (CONTROLLED)
============================================================

OBJECTIVE

Introduce a deterministic operator-controlled approval input
to replace pattern-based approval logic.

This must:

• preserve deterministic execution
• preserve replay guarantees
• preserve isolation guarantees
• preserve hard-stop blocking behavior

────────────────────────────────

APPROVAL INPUT MODEL

Approval decision will be provided explicitly via:

APPROVAL_INPUT

Accepted values:

• APPROVE
• REJECT

Input must be:

• deterministic
• explicit
• non-random
• replayable

────────────────────────────────

EXPECTED BEHAVIOR

If APPROVAL_INPUT = APPROVE:

• approval artifact → operatorApproval = true
• execution proceeds
• execution artifact emitted

If APPROVAL_INPUT = REJECT:

• approval artifact → operatorApproval = false
• approval failure artifact emitted
• execution blocked
• hard stop enforced

────────────────────────────────

ARTIFACT REQUIREMENTS

APPROVAL FILE

• planId
• operatorApproval (true/false)
• approvalId

APPROVAL FAILURE FILE

• planId
• stage = approval
• decision = REJECTED
• reason = OPERATOR_INPUT_REJECTED

────────────────────────────────

INVARIANTS

• approval decision must be deterministic
• same input → same outcome
• rejection must block execution
• governance rejection must still bypass approval
• replay must reproduce identical artifacts

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• approval input model is defined
• approve/reject behavior is explicit
• artifact requirements are defined
• invariants are preserved

