PHASE 457.3 — STATE STORAGE MODEL

STATUS: STRUCTURAL DEFINITION (NO RUNTIME WIRING)

────────────────────────────────

OBJECTIVE

Define how a VALIDATED guidance payload is:

• Stored
• Replaced
• Accessed

Without introducing:

Runtime behavior
Persistence layer
Frontend coupling

────────────────────────────────

CORE PRINCIPLE

There is ALWAYS:

• ONE active guidance payload
• ZERO history
• ZERO accumulation

This is a:

SINGLE-SLOT REPLACEMENT MODEL

────────────────────────────────

STATE SHAPE

GuidanceState:

{
  active: GuidancePayload | null
}

Where:

• active = current valid payload
• null = no valid payload present

No arrays
No logs
No stacking

────────────────────────────────

WRITE RULES

A payload may be written ONLY IF:

• It has passed FULL validation
• It has been FULLY normalized

Then:

REPLACE state.active entirely

NOT merge
NOT patch
NOT extend

────────────────────────────────

REPLACEMENT GUARANTEE

On valid write:

Previous payload is:

• Fully discarded
• Not recoverable
• Not referenced

New payload becomes:

• Sole source of truth

────────────────────────────────

REJECTION BEHAVIOR

If payload fails validation:

• DO NOT modify state.active
• DO NOT partially update
• DO NOT log to state

State remains unchanged

────────────────────────────────

READ GUARANTEE

Consumers of GuidanceState MUST:

• Read ONLY state.active
• Treat as immutable snapshot
• Never mutate payload

If state.active is null:

• Consumer must render fallback (handled outside this phase)

────────────────────────────────

DETERMINISM GUARANTEE

Given identical input sequence:

State transitions MUST be:

• Predictable
• Replayable
• Order-consistent

No timing-based mutation allowed

────────────────────────────────

ISOLATION RULES

GuidanceState MUST NOT:

• Depend on UI state
• Depend on SSE streams
• Depend on external async sources
• Trigger side effects

It is:

PURE STATE CONTAINER

────────────────────────────────

PHASE BOUNDARY

THIS PHASE DOES NOT:

• Implement storage
• Introduce memory layer
• Connect backend
• Connect frontend
• Handle fallback rendering

ONLY defines:

State shape
Replacement model
Read/write rules
Deterministic guarantees

────────────────────────────────

NEXT STEP

PHASE 457.4 — RENDER CONTRACT

Define:

How frontend consumes GuidanceState safely
(without loops, streaming, or mutation)

