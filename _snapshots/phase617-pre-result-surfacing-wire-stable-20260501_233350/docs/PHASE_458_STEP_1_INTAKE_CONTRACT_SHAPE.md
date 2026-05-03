PHASE 458 — STEP 1
INTAKE CONTRACT SHAPE DEFINITION (STRUCTURAL ONLY)

OBJECTIVE

Define the deterministic intake contract shape.

This contract represents the FIRST boundary of FL-3.

No execution.
No planning logic.
No transformation behavior.

Shape only.

────────────────────────────────

INTAKE CONTRACT — INPUT SHAPE

OperatorRequest:

{
  requestId: string
  timestamp: string
  operatorId: string

  rawInput: string

  optionalContext?: {
    projectId?: string
    priorStateRef?: string
    attachments?: string[]
  }
}

Constraints:

• rawInput must remain unmodified
• No parsing at intake boundary
• No enrichment
• No inference

Invariant:

INTAKE DOES NOT INTERPRET

────────────────────────────────

INTAKE CONTRACT — NORMALIZED SHAPE

IntakeEnvelope:

{
  intakeId: string
  receivedAt: string

  operatorRequest: OperatorRequest

  intakeMetadata: {
    source: "operator"
    channel: "dashboard" | "api" | "cli"
  }
}

Constraints:

• Must be deterministic
• No conditional fields
• No mutation of original request
• Envelope must be replay-safe

Invariant:

INPUT → WRAPPED, NOT CHANGED

────────────────────────────────

INTAKE CONTRACT — OUTPUT TARGET (PLANNING HANDOFF)

PlanningInput (TARGET SHAPE ONLY — NO LOGIC):

{
  intakeId: string

  request: {
    rawInput: string
  }

  context: {
    projectId?: string
    priorStateRef?: string
  }
}

Constraints:

• Only structural mapping defined
• No transformation rules implemented yet
• No task generation

Invariant:

INTAKE PREPARES — DOES NOT PLAN

────────────────────────────────

VALIDATION RULES (STRUCTURAL)

Required:

• requestId must exist
• rawInput must be non-empty string
• timestamp must exist

Optional:

• context fields allowed but not required

Failure classification:

• MISSING_REQUIRED_FIELD
• EMPTY_INPUT
• INVALID_SHAPE

No recovery behavior defined.

Validation is:

PASS / FAIL ONLY

────────────────────────────────

ARCHITECTURAL POSITION

Operator
→ Intake (THIS PHASE)
→ Governance
→ Enforcement
→ Execution

Intake role:

• Accept
• Wrap
• Validate
• Forward

Nothing else.

────────────────────────────────

EXPLICIT NON-GOALS

• No NLP parsing
• No task decomposition
• No classification
• No planning logic
• No execution triggering
• No async handling
• No persistence

────────────────────────────────

DETERMINISTIC GUARANTEES

• Same input → same envelope
• No hidden state
• No mutation
• Replay produces identical output

────────────────────────────────

STOP CONDITION

This step is COMPLETE when:

• Contract shape is defined
• Validation rules are defined
• Output target shape is defined

NO CODE WRITTEN
NO SYSTEM MODIFIED

