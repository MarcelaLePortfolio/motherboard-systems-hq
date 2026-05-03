PHASE 470 — STEP 1
GOVERNANCE DECISION INTRODUCTION PLAN

OBJECTIVE

Introduce the FIRST real governance decision boundary while preserving:

• deterministic classification
• deterministic IDs
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

Current governance behavior is structural only:

• governance artifact always emits APPROVED
• no real branching exists
• no rejection path exists

This phase changes that.

────────────────────────────────

TARGET GOVERNANCE BEHAVIOR

Governance must produce one of two deterministic outcomes:

1 — APPROVED
2 — REJECTED

Decision must occur AFTER:

• entry validation
• request classification

Decision must occur BEFORE:

• approval artifact
• execution artifact

────────────────────────────────

INITIAL DECISION RULE (CONTROLLED)

For Phase 470 introduction, governance decision will be based on normalized request class only.

Rule Set:

• V1 — SIMPLE_ECHO → APPROVED
• F1 — EMPTY_INPUT → already blocked at validation
• F2 — EMPTY_INPUT_NORMALIZED → already blocked at validation
• F3 — INPUT_TOO_LONG → already blocked at validation
• F4 — INVALID_CHARACTERS → already blocked at validation
• F5 — MIXED_INVALID_CHARACTERS → already blocked at validation

Additional controlled rejection class introduced:

• V2 — UNSUPPORTED_VALID_PATTERN

Definition:

• printable
• non-empty
• valid characters
• length ≤ 1024
• does NOT begin with "echo "

Governance outcome:

• REJECTED

────────────────────────────────

EXPECTED DECISION SURFACES

APPROVED path:

• governance artifact emitted with decision = APPROVED
• approval artifact emitted
• execution artifact emitted

REJECTED path:

• governance artifact emitted with decision = REJECTED
• governance failure artifact emitted
• approval artifact blocked
• execution artifact blocked

────────────────────────────────

GOVERNANCE FAILURE ARTIFACT

Target file:

docs/proofs/governance_failure_<planId>.json

Minimum fields:

• planId
• stage = governance
• decision = REJECTED
• reason

Initial deterministic rejection reason:

UNSUPPORTED_REQUEST_CLASS

────────────────────────────────

INVARIANTS

• governance decision must be deterministic
• same class → same decision
• rejection must hard-stop downstream execution
• approval must not occur after rejection
• execution must not occur after rejection
• replay must reproduce identical decision artifacts

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• decision plan is defined
• approved and rejected surfaces are explicit
• governance failure artifact shape is defined
• deterministic rejection class is introduced structurally

