PHASE 457.4 — RENDER CONTRACT

STATUS: STRUCTURAL DEFINITION (NO RUNTIME WIRING)

────────────────────────────────

OBJECTIVE

Define how the frontend consumes GuidanceState:

• Safely
• Deterministically
• Without loops
• Without streaming behavior

────────────────────────────────

INPUT

Frontend receives:

GuidanceState.active

Type:

GuidancePayload | null

────────────────────────────────

RENDER RULE

Frontend MUST:

• Replace entire guidance panel
• Use ONLY the current payload
• Perform a single render pass per state change

STRICTLY:

NO append
NO merge
NO accumulation

────────────────────────────────

RENDER TRIGGER (ABSTRACT)

Render may occur ONLY when:

• A NEW valid payload replaces previous state

NOT when:

• DOM mutates
• SSE emits
• UI updates
• Timer ticks

Render is:

STATE-DRIVEN ONLY

────────────────────────────────

IDEMPOTENCY GUARANTEE

Rendering the same payload multiple times MUST:

• Produce identical UI
• Produce no additional side effects

Meaning:

render(payload) === render(payload)

────────────────────────────────

NO FEEDBACK LOOP RULE

Rendering MUST NOT:

• Trigger observers that re-render
• Modify state
• Cause recursive updates

STRICTLY FORBIDDEN:

MutationObserver → render → MutationObserver → render loop

────────────────────────────────

IMMUTABILITY RULE

Frontend MUST treat payload as:

READ-ONLY

It MUST NOT:

• Modify fields
• Enrich payload
• Inject UI-specific fields

────────────────────────────────

FALLBACK BEHAVIOR (ABSTRACT)

If state.active is null:

Frontend MAY render fallback message

BUT:

Fallback MUST NOT:

• Modify state
• Persist
• Trigger updates

────────────────────────────────

RENDER SURFACE

Frontend updates ONLY:

• operator-guidance-response
• operator-guidance-meta

No other UI surfaces touched

────────────────────────────────

DETERMINISM GUARANTEE

Given identical GuidanceState:

UI output MUST be:

• Identical
• Stable
• Replay-safe

No randomness
No time-based formatting
No dynamic injection

────────────────────────────────

PHASE BOUNDARY

THIS PHASE DOES NOT:

• Implement rendering
• Wire to state
• Connect backend
• Introduce event listeners

ONLY defines:

Render rules
Trigger constraints
Loop prevention
Deterministic guarantees

────────────────────────────────

NEXT STEP

PHASE 457.5 — SAFE RENDER ENTRYPOINT

Define:

How rendering is invoked WITHOUT introducing loops or instability

