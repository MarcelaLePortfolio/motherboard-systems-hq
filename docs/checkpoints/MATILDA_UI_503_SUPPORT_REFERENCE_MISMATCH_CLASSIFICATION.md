# Matilda UI 503 — Support Reference Mismatch Classification

Current checkpoint: 78f008a0
Issue resolved: NO

Verified diagnostic result:
- The single authorized diagnostic invocation completed.
- The run was rejected with `UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE`.
- Seven support references were parsed before rejection.
- The conversation reference used the supplied turn identifier.
- The project-context references reveal the concrete mismatch.

Observed invalid project-context reference pattern:
- `relativePath` already contains a `:lineNumber` suffix.
- `lineNumber` is also emitted separately.
- Examples include:
  - `client/src/shell/mission-dashboard-presentation.css:2` with `lineNumber: 2`
  - `client/src/shell/mission-dashboard.css:1` with `lineNumber: 1`
  - `client/src/shell/MissionDashboardWorkspace.tsx:8` with `lineNumber: 8`
  - `docs/MATILDA_CHAT_PHASE2_MILESTONES.md:1` with `lineNumber: 1`
  - `docs/v11-dashboard-bundle-handoff-v3.md:6` with `lineNumber: 6`
  - `docs/architecture-findings/AF-002-react-shell-and-legacy-dashboard-are-distinct-applications.md:9` with `lineNumber: 9`

Classification:
- Exact offending identity is now established.
- Wrong repository path selection is not established.
- Child-line substitution is not established by this evidence.
- The failure is a support-reference serialization/presentation confusion:
  the model copies the rendered `relativePath:lineNumber` display identity into the structured `relativePath` field and then also emits the line number separately.
- The validator correctly rejects these identities because the supplied parent key is constructed from the raw `relativePath` plus `lineNumber`.
- Validator malfunction remains NOT ESTABLISHED.
- Seed/generation-control tuning remains rejected as the solution class.

Important diagnostic-runner note:
- The comparison summary's controlled-arm PASS markers are not meaningful for this one-run diagnostic because `CONTROLLED_RUNS=0`.
- They must not be interpreted as evidence of generation success or production readiness.

Next solution class:
Classify the minimum semantically safe prompt/presentation correction that clearly separates:
1. raw structured `relativePath`,
2. structured `lineNumber`, and
3. human-readable combined source identity.

No production fix is authorized by this classification.

Safety boundary:
- Production prompt change: NOT AUTHORIZED
- Validator change: NOT AUTHORIZED
- Validator weakening: NOT AUTHORIZED
- Model change: NOT AUTHORIZED
- Retry change: NOT AUTHORIZED
- Generation-policy change: NOT AUTHORIZED
- Additional Ollama run: NOT AUTHORIZED
