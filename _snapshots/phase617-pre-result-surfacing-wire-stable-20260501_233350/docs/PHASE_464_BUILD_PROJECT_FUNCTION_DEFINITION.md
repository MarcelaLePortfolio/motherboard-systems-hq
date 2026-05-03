STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Post-Phase 463.3 seal → Phase 464 start — buildProject corridor opened,
single-function implementation posture enforced, deterministic start)

────────────────────────────────

PHASE 464 — buildProject FUNCTION DEFINITION + ISOLATED IMPLEMENTATION

CORRIDOR CLASSIFICATION:

SINGLE FUNCTION RUNTIME SLICE

TARGET:

buildProject ONLY

NO OTHER FUNCTIONS MAY BE IMPLEMENTED IN THIS PHASE

────────────────────────────────

FUNCTION CONTRACT

buildProject(normalized: NormalizedRequest): ProjectDefinition

NormalizedRequest:

• requestId: string
• canonicalText: string
• tokens: string[]
• detectedIntent: "unknown"
• ambiguityFlags: string[]
• normalizationTrace: string[]

ProjectDefinition:

• projectId: string
• sourceRequestId: string
• tasks: TaskDefinition[]
• constraints: string[]
• assumptions: string[]
• unknowns: string[]
• structureTrace: string[]

TaskDefinition:

• taskId: string
• description: string
• dependencies: string[]
• status: "unplanned"

────────────────────────────────

DETERMINISTIC IMPLEMENTATION RULES

projectId:

• MUST be constant for proof phase
• Use: "proj-001"

sourceRequestId:

• MUST pass through exactly from NormalizedRequest.requestId

tasks:

• MUST be deterministically segmented into EXACTLY three tasks
• MUST preserve the Phase 458.1 ordered structure
• MUST use static dependency ordering

Task 1:

• taskId: "task-1"
• description: "define monitoring target"
• dependencies: []
• status: "unplanned"

Task 2:

• taskId: "task-2"
• description: "define uptime check mechanism"
• dependencies: ["task-1"]
• status: "unplanned"

Task 3:

• taskId: "task-3"
• description: "define alert trigger conditions"
• dependencies: ["task-2"]
• status: "unplanned"

constraints:

• ALWAYS []

assumptions:

• ALWAYS []

unknowns:

• EXACTLY:
  - "api endpoints unspecified"
  - "alert delivery method unspecified"

structureTrace:

• EXACTLY:
  - "request segmented into objective"
  - "objective decomposed into ordered steps"

────────────────────────────────

REFERENCE BEHAVIOR

Given NormalizedRequest:

{
  "requestId": "req-001",
  "canonicalText": "create a system that monitors api uptime and alerts me when failures occur",
  "tokens": [
    "create",
    "a",
    "system",
    "that",
    "monitors",
    "api",
    "uptime",
    "and",
    "alerts",
    "me",
    "when",
    "failures",
    "occur"
  ],
  "detectedIntent": "unknown",
  "ambiguityFlags": [],
  "normalizationTrace": [
    "lowercase transformation",
    "punctuation removal",
    "whitespace tokenization"
  ]
}

buildProject MUST return:

{
  "projectId": "proj-001",
  "sourceRequestId": "req-001",
  "tasks": [
    {
      "taskId": "task-1",
      "description": "define monitoring target",
      "dependencies": [],
      "status": "unplanned"
    },
    {
      "taskId": "task-2",
      "description": "define uptime check mechanism",
      "dependencies": ["task-1"],
      "status": "unplanned"
    },
    {
      "taskId": "task-3",
      "description": "define alert trigger conditions",
      "dependencies": ["task-2"],
      "status": "unplanned"
    }
  ],
  "constraints": [],
  "assumptions": [],
  "unknowns": [
    "api endpoints unspecified",
    "alert delivery method unspecified"
  ],
  "structureTrace": [
    "request segmented into objective",
    "objective decomposed into ordered steps"
  ]
}

NO DEVIATION ALLOWED

────────────────────────────────

INTEGRITY RULES

buildProject MUST:

• not mutate input
• not depend on time
• not use randomness
• not use environment branching
• not call external services
• not introduce hidden state
• remain synchronous
• remain intake-only

────────────────────────────────

PHASE 464 SUCCESS CRITERIA

• buildProject contract defined
• deterministic transformation rules fixed
• expected output fixed
• integrity constraints fixed
• implementation may proceed in one file only

────────────────────────────────

NEXT STEP (PHASE 464.1)

• implement buildProject in the selected intake file only
• preserve acceptRawInput and normalize exactly as sealed
• produce isolated runtime proof against Phase 458.1 expected output

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR buildProject IMPLEMENTATION

