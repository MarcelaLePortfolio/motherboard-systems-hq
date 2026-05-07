
# Phase 709 Prompt Assembly Finding

The live `/api/chat/context` endpoint is available and returns compact read-only runtime context.

However, `generateMatildaAdvisoryReply(input)` currently builds `promptLines` from static advisory instructions plus the user message only. It does not inject the `/api/chat/context` payload or an equivalent compact context object into the Ollama prompt.

Result:

- Matilda remains advisory-safe.

- Matilda can mention that surfaced context may exist.

- Matilda cannot reliably summarize the actual current dashboard runtime state from the prompt.

- Next safe implementation should inject a compact static/read-only context block into `promptLines` without changing execution behavior.

Constraints:

- Do not re-enter the failed broad prompt-builder patch approach.

- Patch only a small helper/context string if attempted.

- Keep all curls single-line in scripts.

- Preserve advisory-only and non-executing boundaries.

