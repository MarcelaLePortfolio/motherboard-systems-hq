# Matilda UI 503 — Support Reference Presentation Conflict Authorization Gate

Current checkpoint: 4381c0e8
Issue resolved: NO

Verified classification:
- Structured project-context support uses separate `relativePath` and `lineNumber` fields.
- Parser and fail-closed validator use that same separate-field contract.
- Validator malfunction is not established.
- Model-visible prompt content still presents the same parent identity in combined `path:line` form.
- Conflicting model-visible identity presentation is established.
- The minimum supported implementation is removal of only the combined parent `Display identity = path:line` presentation.

Authorized implementation scope if approved:
- Remove combined parent `Display identity = path:line` lines from model-visible prompt presentation.
- Preserve separate `relativePath = ...` and `lineNumber = ...` fields.
- Preserve output schema.
- Preserve fail-closed provenance validation.
- Preserve selected-context child identity semantics.
- Preserve model, timeout, retries, persistence, and generation policy.

Authorization state:
- Prompt-presentation conflict removal: AWAITING EXPLICIT USER AUTHORIZATION
- Post-change Ollama validation: NOT AUTHORIZED
- Dashboard-visible smoke test: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Output schema change: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Timeout change: NOT AUTHORIZED
- Retry change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Required user decision:
Authorize or decline the bounded prompt-presentation conflict removal.
