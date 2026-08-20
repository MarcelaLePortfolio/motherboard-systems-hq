# Matilda UI 503 — Post-Timeout Validation Result Classification

Current checkpoint: b03d72b1
Issue resolved: NO

Verified result:
- The 90-second Ollama timeout allowed the exact validation request to complete.
- The previous 60-second timeout was therefore a real runtime reliability constraint on this surface.
- The returned response reached existing fail-closed provenance validation.
- Validation rejected the response with `UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE`.
- Six project-context support references were returned.
- All six still embedded `:lineNumber` inside structured `relativePath` while also supplying `lineNumber` separately.
- `RAW_RELATIVE_PATH_PRESENTATION=FAIL`.

Determination:
- Timeout intervention: VALIDATED for this invocation.
- Support-reference prompt-presentation fix: DISPROVEN as sufficient to correct the serialization behavior.
- Existing validator: operating as designed; malfunction not established.
- Validator weakening: not justified.
- Additional timeout change: not justified.
- Dashboard issue: NOT RESOLVED.

Next bounded investigation:
Determine why the model continues copying display-form `path:line` identities into structured `relativePath` despite the explicit raw-path instruction. Prefer inspection of the current prompt/schema/output-contract interaction before any further Ollama invocation or production modification.

Safety boundary:
- Additional Ollama invocation: NOT AUTHORIZED
- Dashboard-visible smoke test: NOT AUTHORIZED
- Prompt change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Validator weakening: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Timeout change: NOT AUTHORIZED
- Retry-policy change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED
