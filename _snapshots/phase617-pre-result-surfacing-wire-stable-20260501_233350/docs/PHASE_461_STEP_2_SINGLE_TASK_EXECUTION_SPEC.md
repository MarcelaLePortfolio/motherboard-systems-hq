PHASE 461 — STEP 2
SINGLE TASK EXECUTION SPEC (FIRST LIVE PATH)

OBJECTIVE

Define the EXACT behavior of the first execution task.

This is the ONLY task allowed in the first live proof.

No expansion beyond this task.

────────────────────────────────

TASK CLASS

Task type:

DETERMINISTIC_ECHO_TASK

Purpose:

• Prove execution path works
• Produce visible, deterministic output
• Avoid side effects

────────────────────────────────

TASK INPUT

From GovernedExecutionTrigger:

approvedTasks[0]

Required fields:

{
  taskId: string
  description: string
}

Constraints:

• Only ONE task allowed
• Must originate from PlanningOutput
• Must be approved by governance + operator

────────────────────────────────

TASK EXECUTION BEHAVIOR

Execution logic (conceptual):

output = "EXECUTION_OK: " + description

Rules:

• No transformation beyond concatenation
• No parsing
• No inference
• No external reads

Invariant:

OUTPUT IS DIRECTLY TRACEABLE TO INPUT

────────────────────────────────

EXECUTION RESULT SHAPE

ExecutionResult:

{
  planId: string
  taskId: string
  status: "SUCCEEDED"
  output: string
}

Constraints:

• status must be SUCCEEDED if executed
• output must match deterministic rule
• no additional fields allowed

────────────────────────────────

FAILURE CONDITIONS

Execution MUST FAIL if:

• more than one task provided
• task not approved
• validation not passed
• missing taskId or description

Failure result:

{
  planId: string
  taskId: string
  status: "FAILED"
  output: "ERROR: <reason>"
}

No partial execution.

────────────────────────────────

EXECUTION ISOLATION

Execution layer MUST NOT:

• read rawInput
• read IntakeEnvelope
• read PlanningInput
• access filesystem
• access network
• mutate state

Execution layer MAY ONLY:

• read approvedTasks
• produce ExecutionResult

Invariant:

EXECUTION IS FULLY SANDBOXED

────────────────────────────────

DETERMINISTIC GUARANTEES

• Same task → same output
• No randomness
• No time dependence
• Replay produces identical result

────────────────────────────────

OBSERVABILITY REQUIREMENTS

Execution must produce:

• ExecutionResult artifact
• linked planId
• linked taskId

Artifact must be:

• written to docs/
• inspectable
• replay-verifiable

────────────────────────────────

EXPLICIT NON-GOALS

• No multi-task execution
• No async processing
• No retries
• No scheduling
• No orchestration
• No persistence system

────────────────────────────────

STOP CONDITION

This step is COMPLETE when:

• task behavior is defined
• execution result shape is defined
• failure conditions are defined
• isolation constraints are enforced

NO CODE WRITTEN
NO SYSTEM MODIFIED

