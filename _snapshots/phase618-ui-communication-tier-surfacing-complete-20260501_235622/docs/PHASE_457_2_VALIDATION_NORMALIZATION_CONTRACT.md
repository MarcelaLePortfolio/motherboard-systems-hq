PHASE 457.2 — VALIDATION + NORMALIZATION CONTRACT

STATUS: STRUCTURAL DEFINITION (NO RUNTIME WIRING)

────────────────────────────────

OBJECTIVE

Define EXACT rules for:

• What constitutes a VALID guidance payload
• How payloads are NORMALIZED before acceptance

This ensures:

Determinism
Consistency
Replay stability
Safe rendering

────────────────────────────────

VALIDATION CONTRACT

A payload is VALID only if ALL conditions pass:

1. STRUCTURE

Payload MUST be an object

Required fields:
• severity (string)
• summary (string)
• detail (string, may be empty)
• source (string)
• confidence (string)
• ts (number)

No missing fields allowed

────────────────────────────────

2. TYPE ENFORCEMENT

• severity → string
• summary → string
• detail → string
• source → string
• confidence → string
• ts → finite number

Reject if any type mismatch

────────────────────────────────

3. CONTENT RULES

summary:
• Must be non-empty after trim
• Must be ≤ 240 characters

detail:
• Optional but must be ≤ 1000 characters

source:
• Must be non-empty
• Must be lowercase kebab-case or system-defined

confidence:
• Must be one of:
  - high
  - medium
  - low

severity:
• Must match format:

  DOMAIN • LEVEL • CONFIDENCE

Example:
SYSTEM_HEALTH • INFO • HIGH

Reject if malformed

────────────────────────────────

4. DETERMINISM RULES

Reject payload if:

• Contains functions
• Contains undefined/null fields
• Contains non-serializable values
• Depends on runtime-only values (e.g. DOM refs)

Payload must be:

JSON-safe
Serializable
Replayable

────────────────────────────────

NORMALIZATION CONTRACT

If payload passes validation:

Apply normalization BEFORE acceptance

────────────────────────────────

1. STRING NORMALIZATION

• Trim all string fields
• Collapse multiple spaces → single space
• Remove leading/trailing newlines

────────────────────────────────

2. SEVERITY NORMALIZATION

• Convert to uppercase
• Ensure spacing:

  "A • B • C"

No extra spaces allowed

────────────────────────────────

3. CONFIDENCE NORMALIZATION

• Lowercase input
• Normalize to:
  high | medium | low

────────────────────────────────

4. SOURCE NORMALIZATION

• Lowercase
• Trim whitespace

────────────────────────────────

5. TIMESTAMP NORMALIZATION

• If ts missing → REJECT (do not auto-fill)
• Must be integer (ms)
• Must be ≥ 0

────────────────────────────────

OUTPUT GUARANTEE

After normalization:

Payload MUST be:

• Fully deterministic
• Fully serializable
• Structurally consistent
• Render-safe

────────────────────────────────

REJECTION GUARANTEE

If ANY validation rule fails:

• Payload is discarded entirely
• No partial normalization
• No fallback mutation
• Previous valid payload remains active

────────────────────────────────

PHASE BOUNDARY

THIS PHASE DOES NOT:

• Implement validation
• Execute normalization
• Connect to UI
• Store state

ONLY defines:

Rules
Constraints
Guarantees

────────────────────────────────

NEXT STEP

PHASE 457.3 — STATE STORAGE MODEL

Define:

How validated guidance is stored and replaced safely

