PHASE 459 — STEP 2
TASK DERIVATION BOUNDARY DEFINITION (DETERMINISTIC, STRUCTURAL)

OBJECTIVE

Define the boundary conditions for future task derivation.

This step does NOT generate tasks.

It defines:

• when task derivation is allowed
• what inputs task derivation may read
• what task derivation may output
• what task derivation is forbidden from doing

Boundary only.

────────────────────────────────

TASK DERIVATION POSITION

OperatorRequest
→ IntakeEnvelope
→ PlanningInput
→ Mapping
→ Task Derivation Boundary (THIS STEP)
→ PlanningOutput
→ Governance
→ Enforcement
→ Execution

Role:

Task derivation is a constrained planning sub-boundary.

It is NOT:

• governance
• enforcement
• execution
• interpretation authority

────────────────────────────────

ALLOWED INPUTS

Task derivation may read ONLY:

• PlanningInput.request.rawInput
• PlanningInput.context.projectId
• PlanningInput.context.priorStateRef
• intakeId
• planId

Constraints:

• No external reads
• No hidden state
• No prior execution state
• No system telemetry
• No environment dependence

Invariant:

TASK DERIVATION MAY ONLY USE EXPLICITLY PROVIDED INPUTS

────────────────────────────────

ALLOWED OUTPUTS

Task derivation may produce ONLY:

tasks: PlannedTask[]

Each PlannedTask may contain ONLY:

{
  taskId: string
  description: string
  status: "PENDING"
  dependencies: string[]
  execution: {
    eligible: false
  }
}

Constraints:

• No execution payloads
• No approval state
• No runtime state
• No hidden metadata

Invariant:

TASKS ARE PLANNING ARTIFACTS ONLY

────────────────────────────────

FORBIDDEN ACTIONS

Task derivation must NEVER:

• trigger execution
• set execution.eligible = true
• assign governance decisions
• infer operator approval
• mutate rawInput
• access network or filesystem
• read async sources
• persist state
• depend on clock randomness
• read UI state

Invariant:

TASK DERIVATION CANNOT ESCAPE ITS BOUNDARY

────────────────────────────────

TASK COUNT CONSTRAINTS

Structural rule set:

• tasks array may be empty
• task count must be derived from input only
• same input must produce same task count
• no probabilistic expansion

At this stage:

• actual derivation logic is still undefined
• empty array remains the valid default

Invariant:

COUNT DETERMINISM PRECEDES TASK CONTENT LOGIC

────────────────────────────────

DEPENDENCY CONSTRAINTS

Dependencies are allowed structurally, but:

• must reference explicit taskIds
• must not form hidden links
• must be replay-stable
• may be empty by default

At this stage:

• dependency generation logic is undefined

Invariant:

DEPENDENCIES MUST BE EXPLICIT OR ABSENT

────────────────────────────────

VALIDATION ALIGNMENT

Any future task derivation output must still satisfy:

• Phase 458 validation matrix
• PlanningOutput contract
• PlannedTask shape rules

If invalid:

• mapping fails
• ValidationResult returned
• no fallback behavior

────────────────────────────────

EXPLICIT NON-GOALS

• No task generation logic
• No semantic decomposition
• No intent parsing
• No prioritization
• No sequencing logic
• No runtime implementation
• No execution preparation

────────────────────────────────

DETERMINISTIC GUARANTEES

• Same explicit inputs → same candidate task set
• No hidden reads
• No mutable dependencies
• No random expansion
• Replay-safe boundary

────────────────────────────────

STOP CONDITION

This step is COMPLETE when:

• allowed inputs are defined
• allowed outputs are defined
• forbidden actions are enumerated
• task derivation confinement is explicit

NO CODE WRITTEN
NO SYSTEM MODIFIED

