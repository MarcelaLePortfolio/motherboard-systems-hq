#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE SOURCE-EXCERPT LIVE — UNSUPPLIED CONVERSATION SUPPORT AFTER HISTORY REMOVAL ==="

EXPECTED_HEAD="c74fbdc2"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches stale-history classification checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^ M scripts/validate-source-excerpt-first-live\.ts$|^\?\? scripts/classify-phase-1-response-composition-state\.sh$|^\?\? scripts/determine-next-response-composition-corridor\.sh$|^\?\? scripts/investigate-source-excerpt-live-support-source-competition\.sh$|^\?\? scripts/reconcile-source-excerpt-live-validator-with-selected-context-contract\.sh$|^\?\? scripts/remove-stale-conversation-support-from-source-excerpt-live-fixture\.sh$|^\?\? scripts/validate-source-excerpt-first-live-contract\.test\.ts$|^\?\? scripts/investigate-unsupplied-conversation-support-after-history-removal\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

cat <<'FINDINGS'
Observed state:

1. The Source-Excerpt-first live fixture now supplies the current
   projectContextSegmentCandidates contract.

2. The stale conversation history has been removed.

3. The fixture therefore supplies no valid conversation-turn provenance.

4. Evidence Composition structural tests continue to pass.

5. The response-contract guard continues to pass.

6. The latest live invocation failed with:

   Ollama returned a conversation support reference that was not supplied in
   this invocation.

7. Runtime therefore correctly rejected model-authored conversation provenance
   outside the supplied conversation source universe.

8. This failure occurs before Evidence Composition assertions can be evaluated.

9. The next required evidence is the exact model-authored support artifact before
   deterministic supplied-source validation.

10. That evidence can be observed through the existing validation-only parsed
    support observer without changing production runtime semantics.

11. The investigation must distinguish whether the emitted conversation source
    is:

    - the historical turn-source-excerpt-live-validation identifier;
    - a different invented source identifier;
    - evidence that stale conversation material remains serialized somewhere;
    - or another occurrence of already-characterized semantic provenance
      variability.

12. Do not implement a corrective hypothesis until the exact artifact is known.

13. Phase 1 remains unestablished.

14. Phase 2 remains blocked.

Do not change ollamaChat.ts.

Do not change server/matilda-chat-workflow.ts.

Do not add history back to the fixture.

Do not force project-context support.

Do not weaken conversation support validation.

Do not repair or silently delete model-authored provenance.

Do not change supportSourceReferences semantics.

Do not change evidenceSufficient.

Do not change Evidence Composition.

Do not weaken selectedContextSegments validation.

Do not add retries.

Do not add another model invocation.

Do not add a production seed.

Do not change model parameters.

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
echo "=== VERIFY LIVE FIXTURE HAS NO CONVERSATION HISTORY ==="
if grep -nE \
  'history:|turn-source-excerpt-live-validation' \
  scripts/validate-source-excerpt-first-live.ts
then
  echo "STOP: conversation history remains in Source-Excerpt live fixture."
  exit 2
fi

echo "SOURCE_EXCERPT_LIVE_CONVERSATION_HISTORY_ABSENT"

echo
echo "=== SEARCH HISTORICAL TURN ID ACROSS ACTIVE INVOCATION SURFACES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'turn-source-excerpt-live-validation' \
  scripts server routes db 2>/dev/null || true

echo
echo "=== SUPPORT OBSERVER SEAM ==="
grep -n -A12 -B8 \
  'observeParsedSupportSourceReferences' \
  scripts/utils/ollamaChat.ts

echo
echo "=== CREATE TEMPORARY DIAGNOSTIC VALIDATOR ==="
python3 <<'PY'
from pathlib import Path

source_path = Path(
    "scripts/validate-source-excerpt-first-live.ts"
)
target_path = Path(
    "scripts/validate-source-excerpt-first-live.diagnostic.tmp.ts"
)

source = source_path.read_text()

old = '''      projectContextSegmentCandidates: [
        suppliedSegment,
      ],
'''

new = '''      projectContextSegmentCandidates: [
        suppliedSegment,
      ],
      observeParsedSupportSourceReferences:
        (references) => {
          console.log(
            "PARSED SUPPORT SOURCE REFERENCES BEFORE VALIDATION",
          );
          console.log(
            JSON.stringify(references, null, 2),
          );
          console.log();
        },
'''

if old not in source:
    raise SystemExit(
        "STOP: expected current child-candidate block not found."
    )

target_path.write_text(
    source.replace(old, new, 1)
)

print(
    "Temporary parsed-support diagnostic validator created."
)
PY

echo
echo "=== LIVE DIAGNOSTIC RUN — EXACTLY ONE INVOCATION ==="
set +e
npx tsx \
  scripts/validate-source-excerpt-first-live.diagnostic.tmp.ts
live_rc=$?
set -e

echo
echo "LIVE_DIAGNOSTIC_EXIT_CODE=$live_rc"

echo
echo "=== REMOVE TEMPORARY DIAGNOSTIC ==="
rm -f \
  scripts/validate-source-excerpt-first-live.diagnostic.tmp.ts

if [[ -e scripts/validate-source-excerpt-first-live.diagnostic.tmp.ts ]]; then
  echo "STOP: temporary diagnostic validator remains."
  exit 2
fi

echo "TEMPORARY_DIAGNOSTIC_REMOVED"

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during diagnostic investigation."
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
echo "SOURCE_EXCERPT_UNSUPPLIED_CONVERSATION_SUPPORT_DIAGNOSTIC_COMPLETE"
echo "PHASE_1_COMPLETION=NOT_YET_ESTABLISHED"
echo "PHASE_2_START=BLOCKED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_MODEL_AUTHORED_CONVERSATION_SUPPORT_FROM_DIAGNOSTIC_OUTPUT"

git add \
  scripts/investigate-unsupplied-conversation-support-after-history-removal.sh

git commit -m "Investigate unsupplied Source-Excerpt conversation support"
git push
