# Matilda UI 503 — Support Reference Prompt Fix Authorization Gate

Current checkpoint: 6ca18065
Issue resolved: NO

Verified diagnosis:
- The model is serializing the combined human-readable `relativePath:lineNumber` identity into the structured `relativePath` field.
- The model separately emits `lineNumber`, producing an invalid duplicated identity.
- The validator correctly expects raw `relativePath` plus separate integer `lineNumber`.
- Validator malfunction is not established.
- Output schema change is not required.
- Generation-control tuning is not the solution class.

Minimum bounded fix:
- Modify only `scripts/utils/ollamaChat.ts`.
- Present parent support identities as explicit structured fields:
  - `relativePath = <raw repository path>`
  - `lineNumber = <integer>`
- Explicitly state that `relativePath` must never contain the `:lineNumber` suffix.
- Preserve the existing `supportSourceReferences` schema.
- Preserve fail-closed provenance validation.
- Preserve selected-context child identity semantics.
- No database or persistence change.
- No retry, timeout, model, or generation-policy change.

Implementation boundary:
- Production prompt presentation change: REQUIRED
- Production prompt presentation change: NOT STARTED
- Implementation authorized: NO
- Validation run after implementation: NOT AUTHORIZED
- Explicit user authorization required: YES

Next action:
Await explicit user authorization to implement this bounded prompt-presentation correction. Any validation invocation after implementation remains a separate authorization boundary.
