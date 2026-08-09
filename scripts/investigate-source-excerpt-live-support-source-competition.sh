#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE SOURCE-EXCERPT LIVE — SUPPORT SOURCE COMPETITION ==="

EXPECTED_HEAD="159a8b93"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches stale-validator classification checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/validate-source-excerpt-first-live\.ts$|^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$|^\?\? scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^\?\? scripts/investigate-source-excerpt-live-support-source-competition\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Observed live result after selected-context reconciliation:

1. The Source-Excerpt-first validator now supplies a valid
   projectContextSegmentCandidates child.

2. The previous failure:

   selected context segment was not supplied

   did not recur.

3. Evidence Composition structural validation passed:

   27 tests passed
   0 failed

4. The structured response contract guard passed.

5. The live invocation completed normally.

6. Matilda's reply correctly referenced the repository evidence.

7. The model-authored support artifact was:

   conversation_turn:
   turn-source-excerpt-live-validation

8. No project_context_excerpt support reference was authored.

9. Consequently:

   evidence = null

10. evidenceSufficient = true

11. This result is internally consistent with the established contracts:

    - supportSourceReferences may contain conversation-turn support;
    - evidenceSufficient is derived from validated support provenance;
    - Source-Excerpt evidence is constructed only from validated
      project-context support;
    - conversation-turn support does not create Source-Excerpt evidence.

12. Therefore the observed null Evidence artifact is not presently evidence of
    a deterministic Evidence Composition defect.

13. The live fixture supplies two competing support universes:

    A. conversation history:
       turn-source-excerpt-live-validation

    B. project-context repository evidence:
       server/matilda-chat-workflow.ts:155

14. The validation question asks specifically:

    What repository evidence shows that this workflow invokes ollamaChat?

15. However, the supplied conversation history itself says:

    We need repository evidence for the workflow invocation seam.

    and:

    The repository excerpt should establish that directly.

16. That history is eligible model input and has a valid sourceTurnId.

17. Under the current support-provenance contract, Matilda may therefore choose
    that conversation turn as support.

18. The historical Source-Excerpt-first validator appears to expect the model to
    choose project-context support even while also supplying independently valid
    conversation-turn support.

19. That expectation must be reconciled against the current support provenance
    contract before changing runtime behavior.

20. The key question is whether the historical conversation fixture is essential
    to the Source-Excerpt-first Evidence Composition behavior being validated.

21. If the test objective is specifically:

    when repository context is the relevant supplied support universe, runtime
    deterministically constructs exact Source-Excerpt evidence from validated
    project-context support

    then unrelated or redundant conversation support may make the fixture
    ambiguous rather than strengthen it.

22. Removing conversation history from a validation fixture would not change
    production runtime semantics.

23. However, that change must not be made until repository evidence confirms
    that conversation history is not part of the behavior this validator is
    intended to prove.

Investigation objective:

Determine whether the Source-Excerpt-first live validator's conversation history
is a stale competing support source that prevents the fixture from isolating
project-context evidence behavior.

Required questions:

A. Why was history originally included in
   validate-source-excerpt-first-live.ts?

B. Did the original Source-Excerpt-first contract require simultaneous
   conversation and repository support?

C. Do current unit tests already prove that conversation support does not create
   Source-Excerpt evidence?

D. Do current unit tests separately prove that validated project-context support
   does create exact Source-Excerpt evidence?

E. Was the live validator intended to validate source-type competition, or only
   repository Source-Excerpt construction?

F. Would removing history from this validation-only fixture preserve the exact
   Evidence Composition behavior under test?

G. Would doing so leave production workflow semantics unchanged?

H. Is a different fixture required if mixed conversation/project support
   competition itself needs behavioral validation?

Required classification:

Exactly one of:

SOURCE_EXCERPT_LIVE_HISTORY_IS_STALE_COMPETING_SUPPORT
SOURCE_EXCERPT_LIVE_MIXED_SUPPORT_IS_REQUIRED
EVIDENCE_COMPOSITION_SUPPORT_SELECTION_BEHAVIOR_UNRESOLVED

Do not implement a fixture change in this unit.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not change supportSourceReferences semantics.

Do not force project-context support.

Do not suppress conversation support in runtime.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not add retries.

Do not add another model invocation.

Do not add a production seed.

Do not change model parameters.

Do not weaken selectedContextSegments validation.

Do not reopen Adaptive Detail.

Do not begin Phase 2.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== CURRENT SOURCE-EXCERPT LIVE FIXTURE ==="
sed -n '1,240p' scripts/validate-source-excerpt-first-live.ts

echo
echo "=== HISTORY OF SOURCE-EXCERPT LIVE VALIDATOR ==="
git show 49bb9054:scripts/validate-source-excerpt-first-live.ts 2>/dev/null || true

echo
echo "=== REFINED SOURCE-EXCERPT LIVE VALIDATOR HISTORY ==="
git show 23dfbe7a:scripts/validate-source-excerpt-first-live.ts 2>/dev/null || true

echo
echo "=== SOURCE-EXCERPT STRUCTURAL TESTS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'conversation support does not create Source-Excerpt evidence|runtime constructs exact Source-Excerpt evidence|model-owned evidence selection is not required|Source-Excerpt' \
  scripts/utils/ollamaChat*.test.ts \
  scripts 2>/dev/null || true

echo
echo "=== SUPPORT SOURCE CONTRACT REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-source-excerpt-live-support-source-competition.sh' \
  -E 'conversation_turn|project_context_excerpt|supportSourceReferences|Source-Excerpt' \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat*.test.ts \
  docs 2>/dev/null || true

echo
echo "=== EVIDENCE COMPOSITION CLOSURE SCRIPT ==="
sed -n '1,320p' scripts/validate-evidence-composition-corridor-closure.sh

echo
echo "=== VERIFY CURRENT STRUCTURAL CONTRACT ==="
npx tsx --test \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during investigation."
  git diff -- \
    scripts/utils/ollamaChat.ts \
    server/matilda-chat-workflow.ts
  exit 2
fi
echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "SOURCE_EXCERPT_LIVE_SUPPORT_SOURCE_COMPETITION_EVIDENCE_COLLECTED"
echo "PHASE_1_COMPLETION=NOT_YET_ESTABLISHED"
echo "PHASE_2_START=BLOCKED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_SOURCE_EXCERPT_LIVE_HISTORY_AGAINST_CURRENT_SUPPORT_CONTRACT"

git add scripts/investigate-source-excerpt-live-support-source-competition.sh
git commit -m "Investigate Source-Excerpt live support competition"
git push
