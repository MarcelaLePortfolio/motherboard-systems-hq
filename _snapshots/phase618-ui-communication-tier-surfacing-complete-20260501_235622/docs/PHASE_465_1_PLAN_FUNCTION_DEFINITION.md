STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Post-Phase 465 prep → Phase 465.1 start — plan corridor opened,
single-function implementation posture enforced, deterministic start)

────────────────────────────────

PHASE 465.1 — plan FUNCTION DEFINITION

CORRIDOR CLASSIFICATION:

SINGLE FUNCTION RUNTIME SLICE

TARGET:

plan ONLY

NO OTHER FUNCTIONS MAY BE IMPLEMENTED IN THIS PHASE

────────────────────────────────

FUNCTION CONTRACT

plan(project: ProjectDefinition): PlanningOutput

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

PlanningOutput:

• projectId: string
• orderedTasks: string[]
• taskGraph: Record<string, string[]>
• planningTrace: string[]
• determinismProof: string

────────────────────────────────

DETERMINISTIC IMPLEMENTATION RULES

projectId:

• MUST pass through exactly from ProjectDefinition.projectId

orderedTasks:

• MUST be EXACTLY:
  - "task-1"
  - "task-2"
  - "task-3"

taskGraph:

• MUST be EXACTLY:
  task-1 → []
  task-2 → ["task-1"]
  task-3 → ["task-2"]

planningTrace:

• EXACTLY:
  - "tasks sequenced by dependency chain"

determinismProof:

• EXACTLY:
  - "linear dependency ordering applied"

────────────────────────────────

REFERENCE BEHAVIOR

Given ProjectDefinition:

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

plan MUST return:

{
  "projectId": "proj-001",
  "orderedTasks": [
    "task-1",
    "task-2",
    "task-3"
  ],
  "taskGraph": {
    "task-1": [],
    "task-2": ["task-1"],
    "task-3": ["task-2"]
  },
  "planningTrace": [
    "tasks sequenced by dependency chain"
  ],
  "determinismProof": "linear dependency ordering applied"
}

NO DEVIATION ALLOWED

────────────────────────────────

INTEGRITY RULES

plan MUST:

• not mutate input
• not depend on time
• not use randomness
• not use environment branching
• not call external services
• not introduce hidden state
• remain synchronous
• remain intake-only

────────────────────────────────

PHASE 465.1 SUCCESS CRITERIA

• plan contract defined
• deterministic ordering rules fixed
• expected output fixed
• integrity constraints fixed
• implementation may proceed in one file only

────────────────────────────────

NEXT STEP (PHASE 465.2)

• implement plan in the selected intake file only
• preserve acceptRawInput, normalize, and buildProject exactly as sealed
• produce isolated runtime proof against Phase 458.1 expected output

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR plan IMPLEMENTATION

