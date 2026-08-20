# Matilda UI 503 — Ollama Timeout Change Authorization Gate

Current checkpoint: 1e4b7e7b
Issue resolved: NO

Verified evidence:
- The existing Ollama client timeout is 60 seconds.
- Pre-fix completed requests already required approximately 54–56 seconds.
- Two post-fix requests were still actively decoding when the client aborted them at approximately 60 seconds.
- The timeout explains why post-fix output did not reach parsing or validation.
- The timeout does not explain or resolve the earlier support-reference serialization defect.
- The support-reference prompt fix remains neither validated nor disproven.

Bounded proposed intervention:
- Change only the existing Ollama client timeout.
- Preserve the current model.
- Preserve the current prompt.
- Preserve the current validator and fail-closed behavior.
- Preserve current retry behavior.
- Preserve current generation policy.
- Preserve database and workflow contracts.
- Establish a rollback boundary to checkpoint 1e4b7e7b.

Authorization state:
- Timeout implementation: NOT AUTHORIZED
- Post-change Ollama validation invocation: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Prompt change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Retry change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Required user decision:
Explicit authorization is required before changing the Ollama client timeout.
