SYSTEM INTERACTION MODEL

Purpose:

Define allowed interaction patterns between major system components.

────────────────────────────────

OPERATOR → GOVERNANCE

Allowed:

Review governance documents
Update governance structure
Define expectations

────────────────────────────────

OPERATOR → EXECUTION

Allowed:

Trigger tasks
Stop tasks
Inspect results

Execution does not self-trigger.

────────────────────────────────

GOVERNANCE → EXECUTION

Allowed:

None.

Governance defines expectations only.
Governance does not control runtime.

────────────────────────────────

COGNITION → OPERATOR

Allowed:

Provide analysis
Provide suggestions

Not allowed:

Decision making
Execution triggering

────────────────────────────────

EXECUTION → REGISTRY

Allowed:

Report state
Report results

────────────────────────────────

REGISTRY → OPERATOR

Allowed:

Provide visibility
Provide history

Not allowed:

Decision logic
Execution authority

────────────────────────────────

ARCHITECTURAL RULE

Information may flow upward.

Authority never flows upward.

────────────────────────────────

INTERACTION PRINCIPLE

Components communicate.
They do not control each other.

