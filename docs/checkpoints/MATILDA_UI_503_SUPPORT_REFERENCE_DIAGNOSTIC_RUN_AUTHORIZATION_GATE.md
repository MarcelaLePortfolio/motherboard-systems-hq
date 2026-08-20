# Matilda UI 503 — Support Reference Diagnostic Run Authorization Gate

Current checkpoint: b2817cf8
Issue resolved: NO

Verified readiness:
- Validation-runner observability is implemented.
- Exact parsed support-reference values will now be recorded for rejected runs.
- Production runtime behavior is unchanged.
- Prompt behavior is unchanged.
- Validator behavior is unchanged.
- No database persistence is introduced.

Proposed diagnostic run:
- Exactly one validation invocation.
- Exact existing dashboard request and project/conversation context.
- Diagnostic purpose only.
- No retry.
- No production persistence.
- No production seed or generation-policy change.
- Capture exact `parsedSupportReferences`.
- Compare each returned project-context support reference with the exact supplied parent project-context identities.
- Classify whether the failure is caused by child-line substitution, invented line numbers, wrong relative paths, conversation/project identity confusion, or another concrete mismatch.

Authorization:
- Diagnostic Ollama invocation: NOT STARTED
- Diagnostic Ollama invocation authorized: NO
- Explicit user authorization required: YES

Safety boundary:
- Production change: NOT AUTHORIZED
- Prompt change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Validator weakening: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Retry change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Next action:
Await explicit user authorization for exactly one bounded diagnostic Ollama invocation using the instrumented validation runner.
