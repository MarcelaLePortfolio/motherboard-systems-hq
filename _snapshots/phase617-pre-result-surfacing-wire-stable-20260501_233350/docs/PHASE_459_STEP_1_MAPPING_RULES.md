PHASE 459 — STEP 1
INTAKE → PLANNING MAPPING RULES (DETERMINISTIC, STRUCTURAL)

OBJECTIVE

Define deterministic mapping rules from:

OperatorRequest
→ PlanningOutput

No task intelligence.
No interpretation logic.
No execution linkage.

RULES ONLY.

────────────────────────────────

MAPPING OVERVIEW

Input:

OperatorRequest

Intermediate:

IntakeEnvelope
→ PlanningInput

Output:

PlanningOutput

Invariant:

ALL TRANSITIONS MUST BE PURE + DETERMINISTIC

────────────────────────────────

RULE SET — LEVEL 1 (IDENTITY MAPPING)

Rule 1:

intakeId = hash(requestId + timestamp)

Constraints:

• Must be deterministic
• No randomness
• Same input → same intakeId

Rule 2:

planId = hash(intakeId)

Constraints:

• One-to-one mapping
• No branching

────────────────────────────────

RULE SET — LEVEL 2 (FIELD PRESERVATION)

Rule 3:

rawInput → PlanningInput.request.rawInput

Constraints:

• No mutation
• No trimming
• No parsing

Rule 4:

optionalContext → PlanningInput.context

Constraints:

• Pass-through only
• No enrichment
• No inference

────────────────────────────────

RULE SET — LEVEL 3 (TASK DERIVATION BOUNDARY)

Rule 5:

tasks = []

Constraints:

• Empty array by default
• No task generation in this step
• Placeholder only

Invariant:

PLANNING STRUCTURE EXISTS BEFORE TASK LOGIC

────────────────────────────────

RULE SET — LEVEL 4 (METADATA GENERATION)

Rule 6:

planMetadata.createdAt = intake.receivedAt

Rule 7:

planMetadata.deterministic = true

Rule 8:

trace.source = "intake"

Rule 9:

trace.mappingVersion = "v1"

Constraints:

• Static values only
• No dynamic inference

────────────────────────────────

RULE SET — LEVEL 5 (VALIDATION ALIGNMENT)

Rule 10:

All outputs must pass:

• Intake validation (L1–L3)
• Planning validation (L4)

Failure behavior:

• Abort mapping
• Return ValidationResult

No fallback.

────────────────────────────────

ARCHITECTURAL POSITION

Operator
→ Intake (defined)
→ Mapping (THIS STEP)
→ PlanningOutput (defined)
→ Governance
→ Enforcement
→ Execution

Mapping role:

• deterministic transformation
• zero interpretation

────────────────────────────────

EXPLICIT NON-GOALS

• No NLP
• No intent detection
• No task generation
• No classification
• No prioritization
• No execution readiness
• No async behavior

────────────────────────────────

DETERMINISTIC GUARANTEES

• Same OperatorRequest → same PlanningOutput
• Hash-based identity ensures repeatability
• No branching logic
• No randomness
• Replay-safe

────────────────────────────────

STOP CONDITION

This step is COMPLETE when:

• All mapping rules are defined
• Identity rules are defined
• Task boundary is enforced (empty set)

NO CODE WRITTEN
NO SYSTEM MODIFIED

