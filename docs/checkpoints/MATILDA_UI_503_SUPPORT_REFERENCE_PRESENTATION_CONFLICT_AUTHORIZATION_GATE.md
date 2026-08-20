# Matilda UI 503 — Support Reference Presentation Conflict Authorization Gate

Current checkpoint: d7292fe7
Issue resolved: NO

Verified current position:
- The QA Recovery Agent post-MVP item is PARKED and should not be re-anchored merely because repository HEAD advances.
- Active engineering work has returned to the Matilda UI 503 investigation.
- The 90-second timeout intervention is IMPLEMENTED AND VALIDATED.
- The remaining blocker is the support-reference serialization conflict.
- Conflicting model-visible `Display identity = path:line` presentation is ESTABLISHED.
- Structured project-context support still requires separate `relativePath` and `lineNumber`.
- Parser and fail-closed validator remain aligned with that separate-field contract.
- Validator malfunction is NOT ESTABLISHED.

Bounded implementation scope if authorized:
- Remove only the combined parent `Display identity = path:line` presentation from model-visible prompt content.
- Preserve separate `relativePath = ...` and `lineNumber = ...` presentation.
- Preserve output schema.
- Preserve fail-closed provenance validation.
- Preserve selected-context child identity semantics.
- Preserve model, timeout, retries, persistence, and generation policy.

Authorization state:
- Prompt-presentation conflict removal: AWAITING EXPLICIT USER AUTHORIZATION
- Post-change Ollama validation: NOT AUTHORIZED
- Dashboard-visible smoke test: NOT AUTHORIZED
- Validator change or weakening: NOT AUTHORIZED
- Output schema change: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Timeout change: NOT AUTHORIZED
- Retry change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Continuity rule:
- Do not continue re-anchoring this authorization gate solely because repository HEAD advances.
- The next repository change should occur only after the user authorizes or declines the bounded prompt-presentation conflict removal.

Required user decision:
Authorize or decline removal of only the conflicting model-visible parent `Display identity = path:line` presentation.
