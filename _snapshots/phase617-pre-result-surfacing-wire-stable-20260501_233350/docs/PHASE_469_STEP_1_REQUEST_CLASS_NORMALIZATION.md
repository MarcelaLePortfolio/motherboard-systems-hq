PHASE 469 — STEP 1
REQUEST CLASS NORMALIZATION

OBJECTIVE

Normalize the expanded bounded request set into explicit, deterministic request classes.

This is a classification step only.

NO behavior change.
NO execution change.
NO governance expansion.

────────────────────────────────

NORMALIZED VALID REQUEST CLASSES

CLASS V1 — SIMPLE_ECHO

Definition:

• input begins with "echo "
• contains printable characters only
• length ≤ 1024
• non-empty after normalization

Examples:

echo hello world
echo hello mars
echo system check
echo deterministic flow

Normalized Behavior:

• passes entry validation
• routed into single-task execution flow
• deterministic IDs derived from normalized input
• full artifact set emitted

────────────────────────────────

NORMALIZED INVALID REQUEST CLASSES

CLASS F1 — EMPTY_INPUT

Definition:

• input is ""

Error Code:

EMPTY_INPUT

────────────────────────────────

CLASS F2 — EMPTY_INPUT_NORMALIZED

Definition:

• input contains only whitespace

Error Code:

EMPTY_INPUT_NORMALIZED

────────────────────────────────

CLASS F3 — INPUT_TOO_LONG

Definition:

• input length > 1024 characters

Error Code:

INPUT_TOO_LONG

────────────────────────────────

CLASS F4 — INVALID_CHARACTERS

Definition:

• input contains non-printable / control characters

Error Code:

INVALID_CHARACTERS

────────────────────────────────

CLASS F5 — MIXED_INVALID_CHARACTERS

Definition:

• input contains both whitespace and control characters

Error Code:

INVALID_CHARACTERS

NOTE:

F4 and F5 intentionally collapse into the same deterministic error class.

────────────────────────────────

CLASS INVARIANTS

Across all request classes:

• classification must be deterministic
• classification must occur before execution path
• classification must not mutate input
• classification must not introduce randomness
• classification must be replay-safe

────────────────────────────────

SUCCESS CRITERIA

Step 1 is complete when:

• all valid request types are grouped into explicit classes
• all invalid request types are grouped into explicit classes
• class definitions are deterministic
• error codes are explicitly mapped
• no execution behavior is modified

