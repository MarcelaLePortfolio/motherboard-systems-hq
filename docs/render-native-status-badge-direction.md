
# Render-Native Status Badge Direction

Status: READY

Corridor: SANDBOX ONLY

Current limitation:

PASS state currently renders as a generic text node using a badge layout token.

Problem:

Status is semantically distinct from ordinary text.

Future direction:

Introduce dedicated semantic node type:

- status_badge

Purpose:

Represent:

- pass/fail state

- warning state

- execution readiness

- reconciliation status

- validation state

- execution gating state

Why this matters:

Status is becoming a first-class artifact object rather than styled text.

Expected benefits:

- clearer ontology separation

- deterministic state rendering

- semantic status propagation

- future execution/reconciliation compatibility

- cleaner renderer contracts

Constraint:

Remain sandbox-only.

Do not integrate into live Preview.

