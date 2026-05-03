PHASE 458 — STEP 2
PLANNING OUTPUT SHAPE DEFINITION (STRUCTURAL ONLY)

OBJECTIVE

Define the deterministic planning output shape.

This is the SECOND boundary required for FL-3 intake completion.

No planning logic.
No task generation behavior.
No execution linkage.

Shape only.

────────────────────────────────

PLANNING OUTPUT — ROOT SHAPE

PlanningOutput:

{
  intakeId: string

  planId: string

  planMetadata: {
    createdAt: string
    deterministic: true
  }

  tasks: PlannedTask[]

  trace: {
    source: "intake"
    mappingVersion: "v1"
  }
}

Constraints:

• planId must be deterministic or derivable
• tasks array must exist (can be empty)
• No dynamic fields allowed

Invariant:

PLANNING OUTPUT IS STRUCTURED — NOT INTELLIGENT

────────────────────────────────

PLANNED TASK SHAPE

PlannedTask:

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

• status MUST be PENDING
• execution.eligible MUST be false
• dependencies must be explicit (empty array if none)

Invariant:

TASKS ARE DECLARED — NOT AUTHORIZED

────────────────────────────────

PLANNING OUTPUT RULES (STRUCTURAL)

• tasks may be empty
• No prioritization logic defined
• No sequencing logic defined
• No enrichment
• No classification

This phase does NOT define:

• how tasks are created
• how many tasks exist
• what tasks mean

Only:

WHAT A VALID PLAN LOOKS LIKE

────────────────────────────────

RELATION TO INTAKE

Input:

PlanningInput (from Step 1)

Output:

PlanningOutput (this step)

Mapping:

DEFINED BUT NOT IMPLEMENTED

Invariant:

INTAKE → PLANNING IS A SHAPE TRANSITION ONLY

────────────────────────────────

VALIDATION RULES

Required:

• intakeId must exist
• planId must exist
• tasks must be array

Each task must:

• have taskId
• have description
• have status = PENDING
• have execution.eligible = false

Failure classification:

• INVALID_PLAN_SHAPE
• INVALID_TASK_SHAPE

No correction logic.

────────────────────────────────

ARCHITECTURAL POSITION

Operator
→ Intake
→ Planning (THIS SHAPE)
→ Governance
→ Enforcement
→ Execution

Planning role (future):

• transform input → tasks

Current phase:

DEFINE ONLY

────────────────────────────────

EXPLICIT NON-GOALS

• No task generation logic
• No AI reasoning
• No prioritization
• No dependency resolution
• No execution eligibility
• No governance interaction
• No async behavior

────────────────────────────────

DETERMINISTIC GUARANTEES

• Same input shape → same output structure
• No randomness
• No inference
• Replay-stable

────────────────────────────────

STOP CONDITION

This step is COMPLETE when:

• Planning output shape is defined
• Task structure is defined
• Validation rules are defined

NO CODE WRITTEN
NO SYSTEM MODIFIED

