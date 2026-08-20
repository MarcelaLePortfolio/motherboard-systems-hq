# Matilda UI 503 — Post-Fix Validation Authorization Gate

Current checkpoint: 36fc0891
Issue resolved: NO

Verified readiness:
- The bounded support-reference prompt-presentation fix is implemented.
- Parent support identities are presented with separate raw `relativePath` and integer `lineNumber` fields.
- The prompt explicitly prohibits a `:lineNumber` suffix inside structured `relativePath`.
- Output schema and fail-closed provenance validation are unchanged.
- No post-fix Ollama validation has been run.

Proposed validation:
- Exactly one bounded Ollama invocation.
- Use the same dashboard request and project/conversation context.
- No retry.
- No database write.
- No further production modification.
- Capture exact parsed support-reference values.
- Verify whether project-context `relativePath` values now contain raw repository paths only.
- Verify whether the invocation passes the existing provenance validator.
- Do not treat one passing invocation alone as full production-stability proof.

Authorization:
- Post-fix validation invocation: NOT STARTED
- Post-fix validation invocation authorized: NO
- Explicit user authorization required: YES

Success boundary:
1. The model no longer embeds `:lineNumber` inside structured `relativePath`.
2. The returned support references satisfy the existing fail-closed provenance validator.
3. No new failure class supersedes the corrected serialization failure.

Safety boundary:
- Additional production change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Validator weakening: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Retry change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED
- Delegation Workspace remains paused.

Next action:
Await explicit user authorization for exactly one post-fix validation invocation.
