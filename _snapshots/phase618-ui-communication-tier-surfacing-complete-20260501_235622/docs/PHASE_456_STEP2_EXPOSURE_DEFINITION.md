PHASE 456 — STEP 2
DASHBOARD EXPOSURE DEFINITION

CLASSIFICATION:
STRUCTURAL EXPOSURE DESIGN

NO RUNTIME MUTATION.

NO ARCHITECTURE CHANGE.

EXPOSURE PLAN ONLY.

────────────────────────────────

OBJECTIVE

Define the minimal exposure additions required to make FL-3
capability clearly visible through the dashboard.

This step defines WHAT to expose,
not HOW to wire it.

Exposure must come from already existing signals only.

────────────────────────────────

EXPOSURE PRINCIPLE

Dashboard must:

Expose truth
Not simulate capability
Not invent signals
Not infer behavior

Only surface what already exists.

────────────────────────────────

REQUIRED EXPOSURE ADDITIONS

1 — MATILDA PLANNING SURFACE

Purpose:

Expose planning cognition already present.

Minimal exposure definition:

Planning Status Panel:

Fields:

• Planning State:
  (idle | planning | ready | blocked)

• Last Planning Activity:
  timestamp

• Planning Output Exists:
  yes/no

• Awaiting Operator Input:
  yes/no

No planning logic added.

Surface only.

────────────────────────────────

2 — EXECUTION READINESS SURFACE

Purpose:

Expose execution eligibility already proven.

Minimal exposure definition:

Execution Readiness Panel:

Fields:

• Execution Status:
  (not ready | ready | awaiting approval | executing)

• Governance Approval State:
  (pending | approved | blocked)

• Execution Path Valid:
  yes/no

• Last Execution Result:
  success | none | blocked

No execution logic added.

Exposure only.

────────────────────────────────

3 — HEALTH SEMANTIC CORRECTION

Purpose:

Align health classification with demo capability.

Current issue:

Health reflects unfinished platform scope.

Required change:

Health classification must reflect:

Demo readiness state.

Proposed semantic tiers:

STRUCTURALLY STABLE
DEMO CAPABLE
RECOVERY REQUIRED
UNSTABLE

NOT:

Platform completeness.

Health must reflect:

Capability truth.

────────────────────────────────

4 — CAPABILITY EXPOSURE SUMMARY

Purpose:

Give operator deterministic awareness of what exists.

Minimal exposure:

Capability Summary Panel:

Fields:

Intake:
PARTIAL

Governance:
PROVEN

Approval Control:
PROVEN

Execution Bridge:
PROVEN

Execution:
PROVEN

Trust/Determinism:
PROVEN

Arbitrary Request Handling:
PARTIAL

Demo Completeness:
COMPLETE

This reflects FL-3 tracking already defined.

No logic added.

Exposure only.

────────────────────────────────

STEP 2 RESULT

Minimal exposure surfaces defined.

No runtime mutation.

No architecture expansion.

No execution expansion.

Checkpoint stability preserved.

────────────────────────────────

NEXT STEP

STEP 3 — Exposure placement definition

Define WHERE these panels should appear on dashboard.

Still exposure only.

