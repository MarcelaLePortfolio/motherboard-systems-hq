#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== CLASSIFY SOURCE-EXCERPT LIVE HISTORY AGAINST CURRENT SUPPORT CONTRACT ==="

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/validate-source-excerpt-first-live\.ts$|^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$|^\?\? scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^\?\? scripts/investigate-source-excerpt-live-support-source-competition\.sh$|^\?\? scripts/classify-source-excerpt-live-history-against-current-support-contract\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== VERIFY ORIGINAL LIVE VALIDATOR HAD NO HISTORY ==="

original="$(
  git show \
    49bb9054:scripts/validate-source-excerpt-first-live.ts
)"

if printf '%s\n' "$original" |
  grep -q 'history:'
then
  echo "STOP: original Source-Excerpt live validator contained history."
  exit 2
fi

echo "ORIGINAL_SOURCE_EXCERPT_VALIDATOR_HISTORY_ABSENT"

echo
echo "=== VERIFY ORIGINAL VALIDATOR USED PROJECT CONTEXT DIRECTLY ==="

if ! printf '%s\n' "$original" |
  grep -q 'projectContextExcerpts'
then
  echo "STOP: original Source-Excerpt live validator did not use project context."
  exit 2
fi

echo "ORIGINAL_PROJECT_CONTEXT_EVIDENCE_PRESENT"

echo
echo "=== VERIFY HISTORY WAS ADDED LATER ==="

refined="$(
  git show \
    23dfbe7a:scripts/validate-source-excerpt-first-live.ts
)"

if ! printf '%s\n' "$refined" |
  grep -q 'history:'
then
  echo "STOP: refined Source-Excerpt validator does not contain expected later history."
  exit 2
fi

echo "LATER_HISTORY_ADDITION_CONFIRMED"

echo
echo "=== VERIFY CURRENT STRUCTURAL SOURCE-EXCERPT OWNERSHIP TESTS ==="

if ! grep -R \
  --include='ollamaChat*.test.ts' \
  -q 'runtime constructs exact Source-Excerpt evidence from validated project-context support' \
  scripts/utils
then
  echo "STOP: project-context Source-Excerpt construction test not found."
  exit 2
fi

if ! grep -R \
  --include='ollamaChat*.test.ts' \
  -q 'conversation support does not create Source-Excerpt evidence' \
  scripts/utils
then
  echo "STOP: conversation-support separation test not found."
  exit 2
fi

echo "PROJECT_CONTEXT_SOURCE_EXCERPT_TEST_PRESENT"
echo "CONVERSATION_SUPPORT_SEPARATION_TEST_PRESENT"

cat <<'FINDINGS'

Classification:

SOURCE_EXCERPT_LIVE_HISTORY_IS_STALE_COMPETING_SUPPORT

Repository-supported determination:

1. The original Source-Excerpt-first live validator at commit 49bb9054 did not
   supply conversation history.

2. Its original live validation shape supplied projectContextExcerpts directly.

3. Therefore simultaneous conversation-turn and project-context support was not
   part of the original Source-Excerpt-first live validation requirement.

4. Conversation history was added later in the refined validator at commit
   23dfbe7a.

5. The current live fixture therefore contains a support source that was not
   required by the original repository-evidence validation scenario.

6. Current Evidence Composition unit tests independently establish both sides of
   the source-type contract:

   A. validated project-context support deterministically constructs exact
      Source-Excerpt evidence;

   B. conversation-turn support does not construct Source-Excerpt evidence.

7. Those behaviors are intentionally distinct.

8. The latest live result is fully consistent with those established semantics:

   supportSourceReferences:
     conversation_turn

   evidence:
     null

   evidenceSufficient:
     true

9. Matilda was allowed to select the supplied conversation turn as support.

10. Runtime correctly respected that support choice.

11. Therefore null Source-Excerpt evidence in that run is not an Evidence
    Composition defect.

12. The live fixture is ambiguous because it asks specifically for repository
    evidence while simultaneously supplying a valid conversation-turn support
    source.

13. That conversation support can satisfy support provenance without producing
    the project-context support reference required for deterministic
    Source-Excerpt construction.

14. The historical mixed-support fixture therefore no longer isolates the
    behavior that Source-Excerpt-first live validation is intended to prove.

15. Removing conversation history from this validation-only fixture restores the
    original support universe:

    project-context repository evidence only.

16. Removing that validation-only history does not alter production workflow
    semantics.

17. It does not suppress conversation support in runtime.

18. It does not force Matilda to select project-context support when both source
    types are supplied.

19. It simply stops this specific Source-Excerpt construction fixture from
    introducing a competing support source unrelated to the isolated behavior
    under validation.

20. Mixed conversation/project-context support selection remains a separate
    semantic behavior if it requires future dedicated validation.

21. That mixed-support behavior must not be conflated with deterministic
    Source-Excerpt construction from validated project-context provenance.

22. The current structural Evidence Composition contract remains supported.

23. The current runtime remains supported.

24. No production Evidence Composition change is justified.

25. No supportSourceReferences semantic change is justified.

26. No evidenceSufficient change is justified.

27. No selectedContextSegments change is justified.

Smallest next unit:

REMOVE_STALE_CONVERSATION_SUPPORT_FROM_SOURCE_EXCERPT_LIVE_FIXTURE

Authorized scope:

- validation artifacts only;
- remove history from validate-source-excerpt-first-live.ts;
- preserve the reconciled projectContextSegmentCandidates child;
- preserve the supplied parent project-context excerpt;
- preserve parent Source identity:
  server/matilda-chat-workflow.ts:155;
- preserve the exact supplied excerpt;
- preserve existing Source-Excerpt-first assertions;
- update the narrow validator-contract test to prove history is absent;
- rerun Evidence Composition structural validation;
- rerun response-contract guard;
- rerun the live Evidence Composition closure check.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not suppress conversation support in production.

Do not force support provenance in runtime.

Do not change supportSourceReferences.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not weaken selectedContextSegments validation.

Do not add retries.

Do not add another model invocation.

Do not add a production seed.

Do not change model parameters.

Do not reopen Adaptive Detail.

Do not begin Phase 2.

Phase 1 completion remains unestablished until the reconciled closure check
passes.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during classification."
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
echo "SOURCE_EXCERPT_LIVE_HISTORY_IS_STALE_COMPETING_SUPPORT"
echo "PHASE_1_COMPLETION=NOT_YET_ESTABLISHED"
echo "PHASE_2_START=BLOCKED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_UNIT=REMOVE_STALE_CONVERSATION_SUPPORT_FROM_SOURCE_EXCERPT_LIVE_FIXTURE"

git add \
  scripts/classify-source-excerpt-live-history-against-current-support-contract.sh && \
git commit -m "Classify stale Source-Excerpt live history support" && \
git push
