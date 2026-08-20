# Matilda UI 503 — Post-Change Ollama Validation Authorization Gate

Current checkpoint: 2333c99f
Issue resolved: NO

Verified current position:
- The bounded support-reference prompt-presentation correction is IMPLEMENTED.
- Implementation commit: 2f8bc31e.
- Classification commit: 2333c99f.
- The two conflicting model-visible parent `Display identity = path:line` lines were removed.
- Separate `relativePath` and `lineNumber` presentation remains.
- Output schema and fail-closed validator remain unchanged.
- Model, timeout, retries, persistence, generation policy, and database behavior remain unchanged.
- The known unrelated Atlas TS2554 typecheck error remains.
- No post-change Ollama validation has been run.
- No dashboard-visible smoke test has been run.

Validation scope if authorized:
- Run exactly one exact post-change Ollama validation invocation using the existing bounded dashboard validation surface.
- Use the existing 90-second timeout.
- Do not run a controlled/seeded comparison.
- Do not run a dashboard-visible smoke test.
- Do not modify validator, schema, model, timeout, retries, persistence, generation policy, or database behavior.
- Classify whether project-context support references now serialize raw `relativePath` separately from `lineNumber`.
- Preserve fail-closed rejection if malformed support references remain.

Authorization state:
- One exact post-change Ollama validation invocation: AWAITING EXPLICIT USER AUTHORIZATION
- Additional Ollama invocations: NOT AUTHORIZED
- Dashboard-visible smoke test: NOT AUTHORIZED
- Production correction beyond the implemented prompt change: NOT AUTHORIZED

Required user decision:
Authorize or decline exactly one post-change Ollama validation invocation.
