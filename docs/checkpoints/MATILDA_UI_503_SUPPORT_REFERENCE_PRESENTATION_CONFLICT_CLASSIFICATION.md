# Matilda UI 503 — Support Reference Presentation Conflict Classification

Current checkpoint: ecb0c320
Issue resolved: NO

Verified evidence:
- The structured output contract represents project-context support with separate `relativePath` and `lineNumber` fields.
- The parser and fail-closed provenance validator use the same separate-field identity contract.
- Validator malfunction is not established.
- The prompt explicitly instructs the model to keep `relativePath` raw and copy `lineNumber` separately.
- Despite that instruction, model-visible prompt content still presents the same parent support identity in combined `path:line` form as `Display identity`.
- The combined display form appears in both bounded project-context evidence and parent support-provenance presentation.
- The model subsequently reproduces that same combined `path:line` form inside structured `relativePath`.
- The prior prompt correction therefore introduced competing presentations of the same identity rather than eliminating the ambiguous representation.

Classification:
- Output schema ambiguity: NOT ESTABLISHED.
- Validator identity mismatch: NOT ESTABLISHED.
- Raw-path instruction absence: NOT ESTABLISHED.
- Conflicting model-visible identity presentation: ESTABLISHED.
- Combined `Display identity = path:line` remains a plausible direct source of the repeated serialization behavior.

Minimum next implementation class:
- Remove combined parent `Display identity = path:line` lines from model-visible prompt presentation.
- Preserve separate `relativePath = ...` and `lineNumber = ...` fields.
- Preserve the structured output schema.
- Preserve fail-closed provenance validation.
- Preserve child selected-context identity semantics.
- Do not normalize or repair malformed model output after generation.
- Do not weaken validator membership checks.
- Do not change model, timeout, retries, persistence, or generation policy.

Authorization boundary:
- Prompt-presentation conflict removal: NOT STARTED.
- Implementation authorized: NO.
- Post-change Ollama validation: NOT AUTHORIZED.
- Explicit user authorization required before implementation.

Safety boundary:
- Additional Ollama invocation: NOT AUTHORIZED
- Dashboard-visible smoke test: NOT AUTHORIZED
- Prompt change: NOT AUTHORIZED
- Output schema change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Validator weakening: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Timeout change: NOT AUTHORIZED
- Retry-policy change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Next action:
Await explicit user authorization to remove only the conflicting model-visible parent `Display identity = path:line` presentation. Validation after that implementation remains separately gated.
