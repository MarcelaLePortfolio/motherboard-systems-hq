PHASE 457 — GUIDANCE INJECTION CONTRACT

STATUS: DEFINITION PHASE (NO RUNTIME WIRING)

────────────────────────────────

OBJECTIVE

Define a deterministic, structured injection contract for operator guidance.

This replaces:

Static baseline message (Phase 456)

With:

Controlled, single-message guidance injection point

────────────────────────────────

CONTRACT NAME

OperatorGuidanceInjectionContract

────────────────────────────────

REQUIRED STRUCTURE

A valid guidance payload MUST conform to:

{
  "severity": "SYSTEM_HEALTH • INFO • HIGH",
  "summary": "System operational. Awaiting operator input.",
  "detail": "",
  "source": "deterministic-engine",
  "confidence": "high",
  "ts": 0
}

────────────────────────────────

FIELD DEFINITIONS

severity:
• Uppercase classification string
• Must follow: DOMAIN • LEVEL • CONFIDENCE

summary:
• Primary operator-facing message
• Single sentence preferred

detail:
• Optional expansion
• Must NOT duplicate summary

source:
• Origin of guidance signal
• Examples:
  - deterministic-engine
  - governance-evaluation
  - intake-analysis

confidence:
• Required
• Allowed:
  - high
  - medium
  - low

ts:
• Epoch timestamp (ms)
• Used for ordering + freshness

────────────────────────────────

INVARIANTS

• Exactly ONE guidance message active at a time
• No streaming updates
• No partial payloads
• No mutation after injection
• Must be replay-stable
• Must be render-safe (no HTML injection)

────────────────────────────────

REJECTION RULES

Payload MUST be rejected if:

• Missing required fields
• Empty summary
• Invalid severity format
• Non-deterministic structure
• Contains streaming artifacts

────────────────────────────────

RENDER EXPECTATION

Frontend must:

• Replace entire guidance panel
• Not append
• Not accumulate history
• Not animate stream

────────────────────────────────

PHASE BOUNDARY

THIS PHASE DOES NOT:

• Connect backend
• Introduce SSE
• Introduce polling
• Modify runtime behavior

ONLY defines:

Shape
Rules
Constraints

────────────────────────────────

NEXT STEP

PHASE 457.1 — INJECTION ENTRYPOINT SHAPE

We will define:

How this contract enters the system safely

