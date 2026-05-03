PHASE 472 — STEP 1
APPROVAL LAYER INTRODUCTION PLAN

OBJECTIVE

Introduce the first real approval decision boundary after governance approval while preserving:

• deterministic request classification
• deterministic governance branching
• deterministic artifacts
• replay guarantees
• single-path execution model

This step is:

CONTROLLED
DETERMINISTIC
NON-ASYNC
SINGLE-TASK
NO-UI

────────────────────────────────

CURRENT STATE

Current approval behavior is structural only:

• approval artifact always emits operatorApproval = true
• no real approval branching exists
• no approval rejection path exists

This phase changes that.

────────────────────────────────

TARGET APPROVAL BEHAVIOR

Approval must produce one of two deterministic outcomes:

1 — APPROVED
2 — REJECTED

Approval decision must occur AFTER:

• entry validation
• request classification
• governance approval

Approval decision must occur BEFORE:

• execution artifact emission

────────────────────────────────

INITIAL DECISION RULE (CONTROLLED)

For Phase 472 introduction, approval decision will be based on supported approved request pattern only.

Rule Set:

• governance APPROVED + input begins with "echo " → APPROVED
• governance REJECTED → approval not reached

Additional controlled approval rejection class introduced:

• A2 — APPROVAL_REJECTED_PATTERN

Definition:

• governance outcome = APPROVED candidate
• printable
• non-empty
• valid characters
• length ≤ 1024
• begins with "echo reject "

Approval outcome:

• REJECTED

Initial deterministic rejection reason:

OPERATOR_REJECTED_PATTERN

────────────────────────────────

EXPECTED APPROVAL SURFACES

APPROVED path:

• approval artifact emitted with operatorApproval = true
• execution artifact emitted

REJECTED path:

• approval artifact emitted with operatorApproval = false
• approval failure artifact emitted
• execution artifact blocked

────────────────────────────────

APPROVAL FAILURE ARTIFACT

Target file:

docs/proofs/approval_failure_<planId>.json

Minimum fields:

• planId
• stage = approval
• decision = REJECTED
• reason

Initial deterministic rejection reason:

OPERATOR_REJECTED_PATTERN

────────────────────────────────

INVARIANTS

• approval decision must be deterministic
• same class → same approval outcome
• approval rejection must hard-stop downstream execution
• execution must not occur after approval rejection
• governance rejection must still block approval entirely
• replay must reproduce identical approval decision artifacts

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• approval decision plan is defined
• approved and rejected approval surfaces are explicit
• approval failure artifact shape is defined
• deterministic approval rejection class is introduced structurally

