PHASE 458 — STEP 3
INTAKE + PLANNING VALIDATION MATRIX (STRUCTURAL ONLY)

OBJECTIVE

Define a unified validation matrix for:

• OperatorRequest (input)
• IntakeEnvelope (wrapped input)
• PlanningOutput (target structure)

This completes the deterministic intake boundary.

No runtime validation logic.
No enforcement wiring.

Definition only.

────────────────────────────────

VALIDATION LAYERS

L1 — INPUT VALIDATION (OperatorRequest)

Required:

• requestId → string, non-empty
• timestamp → string
• operatorId → string
• rawInput → string, non-empty

Failure cases:

• MISSING_REQUEST_ID
• MISSING_TIMESTAMP
• MISSING_OPERATOR_ID
• EMPTY_RAW_INPUT

────────────────────────────────

L2 — ENVELOPE VALIDATION (IntakeEnvelope)

Required:

• intakeId → string
• receivedAt → string
• operatorRequest → valid OperatorRequest
• intakeMetadata.source → "operator"
• intakeMetadata.channel → valid enum

Failure cases:

• INVALID_ENVELOPE_SHAPE
• INVALID_METADATA
• INVALID_OPERATOR_REQUEST

────────────────────────────────

L3 — PLANNING INPUT VALIDATION

Required:

• intakeId → string
• request.rawInput → string

Optional:

• context.projectId
• context.priorStateRef

Failure cases:

• INVALID_PLANNING_INPUT
• MISSING_RAW_INPUT

────────────────────────────────

L4 — PLANNING OUTPUT VALIDATION

Required:

• intakeId → string
• planId → string
• tasks → array

Each task:

• taskId → string
• description → string
• status → "PENDING"
• dependencies → array
• execution.eligible → false

Failure cases:

• INVALID_PLAN_SHAPE
• INVALID_TASK_SHAPE
• INVALID_TASK_STATUS
• INVALID_EXECUTION_FLAG

────────────────────────────────

VALIDATION EXECUTION MODEL (STRUCTURAL)

Validation is:

• deterministic
• synchronous (conceptually)
• pass/fail only

No:

• mutation
• correction
• fallback behavior

Invariant:

INVALID INPUT DOES NOT PROCEED

────────────────────────────────

FAILURE SURFACE (EXPOSURE SHAPE)

ValidationResult:

{
  valid: boolean

  errors: [
    {
      code: string
      field: string
    }
  ]
}

Constraints:

• errors must be explicit
• no hidden failures
• no inferred corrections

────────────────────────────────

ARCHITECTURAL POSITION

Operator
→ Intake (validate input)
→ Envelope (validate structure)
→ Planning Input (validate mapping)
→ Planning Output (validate structure)
→ Governance

Validation role:

• gate correctness
• preserve determinism

NOT:

• fix input
• interpret meaning
• trigger execution

────────────────────────────────

EXPLICIT NON-GOALS

• No schema libraries
• No runtime validators
• No transformation logic
• No enrichment
• No error recovery
• No async validation

────────────────────────────────

DETERMINISTIC GUARANTEES

• Same invalid input → same errors
• Same valid input → pass
• No variability
• Replay-safe validation results

────────────────────────────────

STOP CONDITION

This step is COMPLETE when:

• All validation layers are defined
• Failure cases are enumerated
• Validation result shape is defined

PHASE 458 (INTAKE CONTRACT DEFINITION) IS NOW:

STRUCTURALLY COMPLETE

