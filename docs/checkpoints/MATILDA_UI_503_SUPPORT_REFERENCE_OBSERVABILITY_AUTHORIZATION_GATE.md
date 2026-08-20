# Matilda UI 503 — Support Reference Observability Authorization Gate

Current checkpoint: b0c6a05c
Issue resolved: NO

Verified evidence:
- Prompt and validator parent identity shapes are aligned.
- Validator malfunction is not established.
- The existing parsed-support-reference observer executes before membership rejection.
- The validation runner currently records only the number of parsed support references.
- Exact model-authored support-reference values are therefore still unavailable.
- No new production observability seam is required.

Minimum implementation:
- Modify only `scripts/run-dashboard-generation-control-comparison.ts`.
- Extend `RunRecord` to capture the already-observed parsed support-reference values.
- Include those values for both accepted and rejected validation runs.
- Do not modify `ollamaChat.ts`.
- Do not modify the prompt.
- Do not modify provenance validation.
- Do not persist anything to the database.
- Do not start a new Ollama invocation as part of this implementation step.

Purpose:
Expose the exact model-authored support references so they can be compared with the exact supplied parent identities and the provenance failure can be classified directly.

Authorization:
- Validation-runner observability implementation: NOT STARTED
- Implementation authorized: NO
- New Ollama experiment authorized: NO
- Explicit user authorization required: YES

Safety boundary:
- Production change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Validator weakening: NOT AUTHORIZED
- Prompt change: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Next action:
Await explicit user authorization to implement the validation-runner-only observability change. A separate authorization boundary remains required before using that instrumentation in a new Ollama validation run.
