# Matilda UI 503 — Support Reference Presentation Conflict Authorization Gate

Current checkpoint: 4381c0e8
Issue resolved: NO

Current position:
- The original dashboard 503 investigation has isolated two separate problems.
- The 60-second Ollama timeout was proven to be a real runtime reliability constraint and was increased to 90 seconds.
- Post-timeout validation successfully completed generation, proving the timeout intervention worked.
- That completed response exposed the remaining blocker: all six project-context support references still serialized `relativePath` as `path:lineNumber`.
- The fail-closed validator correctly rejected those references.
- The first prompt-presentation correction was therefore disproven as sufficient.
- Subsequent non-Ollama inspection established that the prompt still exposes competing identity representations: separate `relativePath` / `lineNumber` fields plus combined `Display identity = path:line`.
- The minimum supported next change is removal of only that conflicting combined parent display identity.

Authorization state:
- Timeout intervention: IMPLEMENTED AND VALIDATED
- Support-reference serialization defect: STILL ACTIVE
- Prompt-presentation conflict removal: AWAITING EXPLICIT USER AUTHORIZATION
- Post-change Ollama validation: NOT AUTHORIZED
- Dashboard-visible smoke test: NOT AUTHORIZED
- Validator change or weakening: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Additional timeout change: NOT AUTHORIZED
- Retry or generation-policy change: NOT AUTHORIZED

Progress assessment:
- The investigation has taken a while because the timeout temporarily prevented us from observing the original serialization failure.
- That detour is now resolved and causally classified.
- We are no longer broadly diagnosing the 503.
- We are at a narrow implementation gate for the remaining known serialization defect.
- If the bounded prompt change succeeds in validation, the next step is the visible dashboard smoke test required for final issue closure.

Required user decision:
Authorize or decline removal of only the conflicting model-visible parent `Display identity = path:line` presentation.
