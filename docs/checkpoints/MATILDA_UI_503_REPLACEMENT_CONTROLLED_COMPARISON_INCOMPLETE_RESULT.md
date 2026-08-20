# Matilda UI 503 — Replacement Controlled Comparison Incomplete Result

Current checkpoint: 91f0a72f
Issue resolved: NO

Verified result:
- Controlled run blocks captured: 10/10
- Fully accepted controlled runs: 0
- Explicit controlled rejections captured: 9
- Repeated failure class: UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE
- Runs 1-9 each failed with the same project-context provenance rejection.
- Run 10 marker was captured, but its completed result body was not captured.
- COMPARISON SUMMARY was not captured.
- ACCEPTANCE BOUNDARY was not captured.
- Therefore the replacement comparison is incomplete and cannot be treated as a completed 10-run experiment.

Interpretation:
The fixed seed 424242 did not demonstrate the intended reliability improvement in the captured evidence. At least 9 of the controlled runs failed with the same provenance class seen on the unseeded surface, so the controlled-generation hypothesis is strongly disfavored even though the final run and formal summary are incomplete.

Failure containment:
- Do not start another experiment from this checkpoint.
- Do not promote seed 424242 to production.
- Do not weaken the validator.
- Do not change model, retries, timeout, or persistence.
- This is the second failed execution attempt under the replacement controlled-comparison hypothesis.
- A third attempt is not justified unless new evidence identifies a specific reason run 10 / final summary capture failed that can be corrected cleanly.

Next action:
Investigate why the replacement runner terminated or stopped after emitting CONTROLLED RUN 10/10, using the committed result and runner implementation only. Determine whether this was a runner/capture failure, timeout, or other bounded execution failure before deciding whether any final retry is justified.
