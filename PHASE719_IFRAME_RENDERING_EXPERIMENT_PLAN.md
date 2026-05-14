
# PHASE 719 — ISOLATED IFRAME/SRCDOC RENDERING CORRIDOR

STATUS:

- Stable markdown artifact visibility baseline preserved

- Runtime healthy

- Worker healthy

- Dashboard healthy

- Postgres healthy

- Retry architecture preserved

- Artifact preview route operational

- Shared artifact volume verified

- Current authoritative checkpoint: 5f4cd622

GOAL:

Introduce isolated iframe/srcdoc preview experimentation WITHOUT modifying:

- worker artifact contracts

- persistence contracts

- retry architecture

- DB schema

- execution pipeline

- SSE lifecycle

- task completion semantics

STRICT BOUNDARIES:

- UI-only experimentation

- No worker mutation

- No backend artifact generation mutation

- No speculative payload surgery

- No exact-string patching

- No inline HTML persistence redesign

SAFE TARGET:

Render existing markdown-derived preview HTML inside:

- iframe

OR

- srcdoc container

PURPOSE:

- isolate rendering behavior

- improve preview containment

- prevent modal contamination

- establish future embedded rendering corridor

WITHOUT redefining artifact contracts

IMPLEMENTATION STRATEGY:

1. Preserve existing preview modal logic

2. Preserve existing markdown transformation pipeline

3. Add optional iframe rendering layer only

4. Gate behind isolated renderer helper

5. Allow immediate rollback by removing renderer wrapper only

INITIAL TECHNICAL APPROACH:

- Build isolated renderer helper

- Inject transformed HTML into iframe srcdoc

- Keep artifact route read-only

- Do not trust raw artifact HTML

- Sanitize transformed output before injection

- Maintain execution trace suppression

VALIDATION CHECKLIST:

- Preview pill still functional

- Modal still opens

- Task polling unaffected

- SSE unaffected

- Retry/requeue unaffected

- No console instability

- No modal freeze

- No scroll regression

- No dashboard rebuild regression

- No container instability

ROLLBACK RULE:

If rendering instability appears:

- revert immediately

- do not layer fixes

- preserve stable baseline

SUCCESS CONDITION:

- Preview renders inside isolated iframe/srcdoc container

- Runtime stability preserved

- Existing artifact contracts untouched

- No execution regressions introduced

AUTHORITATIVE RULE:

UI experimentation only.

Artifact contract redesign remains deferred.

