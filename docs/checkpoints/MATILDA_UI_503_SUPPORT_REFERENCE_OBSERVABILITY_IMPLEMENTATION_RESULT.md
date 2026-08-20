# Matilda UI 503 — Support Reference Observability Implementation Result

Current checkpoint: b64ffbf5
Issue resolved: NO

Verified implementation:
- Validation-runner observability was implemented in `scripts/run-dashboard-generation-control-comparison.ts`.
- `RunRecord` now records exact parsed support-reference values in `parsedSupportReferences`.
- Values are captured for both accepted and rejected runs.
- The existing `observeParsedSupportSourceReferences` seam is reused.
- No `ollamaChat.ts` change was made.
- No prompt change was made.
- No validator change or weakening was made.
- No database persistence was added.
- No Ollama validation run was started by this implementation.

Verification:
- The implementation diff is bounded to validation instrumentation plus its implementation helper.
- Repository-wide `npx tsc --noEmit` remains blocked by the pre-existing unrelated `routes/atlas/why.ts` TS2554 error: `reconstructWhy` is called with three arguments where two are expected.
- This type error was already known and is not evidence of failure in the observability implementation.

Authorization boundary:
- Observability implementation: COMPLETE
- New Ollama validation run: NOT AUTHORIZED
- Production change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Prompt change: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED

Next action:
Open a separate authorization gate for one bounded validation invocation using the instrumented runner to capture the exact model-authored support-reference values. The purpose of that invocation is diagnostic only: compare returned references with supplied parent project-context identities and classify the provenance mismatch.
