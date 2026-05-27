PHASE 81.6 — Queue Pressure Classification Verification Harness

Objective:

Add deterministic verification coverage for the Phase 81.5
queue pressure classification model.

Scope:

Test harness only.
No reducer changes.
No dashboard wiring.
No runtime coupling.

Verification targets:

Boundary correctness
Clamp behavior
Unknown handling
Deterministic outputs

Required test cases:

CASE 1 — zero
Input: 0
Expected: LOW

CASE 2 — just below elevated
Input: 0.249
Expected: LOW

CASE 3 — elevated boundary
Input: 0.25
Expected: ELEVATED

CASE 4 — just below high
Input: 0.499
Expected: ELEVATED

CASE 5 — high boundary
Input: 0.50
Expected: HIGH

CASE 6 — just below critical
Input: 0.749
Expected: HIGH

CASE 7 — critical boundary
Input: 0.75
Expected: CRITICAL

CASE 8 — max theoretical
Input: 1.0
Expected: CRITICAL

CASE 9 — undefined
Input: undefined
Expected: UNKNOWN

CASE 10 — negative safety clamp
Input: -0.10
Expected: LOW

CASE 11 — overflow safety clamp
Input: 5
Expected: CRITICAL

Verification rules:

• All cases must pass deterministically
• No floating rounding variance allowed
• No environment dependence
• No time dependence
• No telemetry dependencies

Suggested harness structure:

tests/signal/queue_pressure_classification.test.ts

Harness rules:

Pure function import only.

No reducer imports.
No dashboard imports.
No runtime imports.

Phase completion criteria:

All boundary tests implemented
All tests passing
No side effects
No coupling introduced

Completion advances system toward:

Phase 81.7 registry entry
Phase 81.8 signal layer closure

