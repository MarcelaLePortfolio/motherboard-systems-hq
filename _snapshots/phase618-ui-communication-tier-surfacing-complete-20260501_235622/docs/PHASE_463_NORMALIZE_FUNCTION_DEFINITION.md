STATE HANDOFF — DO NOT LOSE CONTEXT

ASSISTANT OPERATES IN ENGINEERING CONTINUATION MODE

(Post-Phase 462.11 seal → Phase 463 start — normalize corridor opened,
single-function implementation posture enforced, deterministic start)

────────────────────────────────

PHASE 463 — normalize FUNCTION DEFINITION + ISOLATED IMPLEMENTATION

CORRIDOR CLASSIFICATION:

SINGLE FUNCTION RUNTIME SLICE

TARGET:

normalize ONLY

NO OTHER FUNCTIONS MAY BE IMPLEMENTED IN THIS PHASE

────────────────────────────────

FUNCTION CONTRACT

normalize(request: OperatorRequest): NormalizedRequest

OperatorRequest:

• requestId: string
• timestamp: number
• rawInput: string
• inputType: "text"
• source: "operator"
• metadata: Record<string, unknown>

NormalizedRequest:

• requestId: string
• canonicalText: string
• tokens: string[]
• detectedIntent: "unknown"
• ambiguityFlags: string[]
• normalizationTrace: string[]

────────────────────────────────

DETERMINISTIC IMPLEMENTATION RULES

requestId:

• MUST pass through exactly from OperatorRequest

canonicalText:

• MUST be lowercased
• MUST remove punctuation
• MUST preserve word order
• MUST collapse to whitespace-tokenized form compatible with Phase 458.1 proof

tokens:

• MUST be produced from canonicalText
• MUST split on whitespace only
• MUST preserve deterministic order

detectedIntent:

• ALWAYS "unknown"

ambiguityFlags:

• ALWAYS []

normalizationTrace:

• EXACTLY:
  - "lowercase transformation"
  - "punctuation removal"
  - "whitespace tokenization"

────────────────────────────────

REFERENCE BEHAVIOR

Given OperatorRequest.rawInput:

"Create a system that monitors API uptime and alerts me when failures occur."

normalize MUST return:

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

NO DEVIATION ALLOWED

────────────────────────────────

INTEGRITY RULES

normalize MUST:

• not mutate input
• not depend on time
• not use randomness
• not use environment branching
• not call external services
• not introduce hidden state
• remain synchronous
• remain intake-only

────────────────────────────────

PHASE 463 SUCCESS CRITERIA

• normalize contract defined
• deterministic transformation rules fixed
• expected output fixed
• integrity constraints fixed
• implementation may proceed in one file only

────────────────────────────────

NEXT STEP (PHASE 463.1)

• implement normalize in the selected intake file only
• preserve acceptRawInput exactly as sealed
• produce isolated runtime proof against Phase 458.1 expected output

────────────────────────────────

STATE

STABLE
GUARDED
DETERMINISTIC
READY FOR normalize IMPLEMENTATION

