#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE COMPOSITION CORRIDOR CLOSURE ==="

echo
echo "=== REPOSITORY STATE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== STRUCTURAL VALIDATION ==="
npx tsx --test \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.explanation-status.test.ts \
  scripts/utils/ollamaChat.explanation-request.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== LIVE SOURCE-EXCERPT-FIRST VALIDATION ==="
set +e
live_output="$(
  npx tsx scripts/validate-source-excerpt-first-live.ts 2>&1
)"
live_rc=$?
set -e

printf '%s\n' "$live_output"

if [[ $live_rc -ne 0 ]]; then
  echo
  echo "EVIDENCE_COMPOSITION_NOT_CLOSED: live validation failed with exit code $live_rc."
  exit 1
fi

if ! grep -q \
  "SOURCE_EXCERPT_FIRST_LIVE_SUPPORTED" \
  <<<"$live_output"
then
  echo
  echo "EVIDENCE_COMPOSITION_NOT_CLOSED: live validation did not report supported behavior."
  exit 1
fi

echo
echo "=== CLOSURE FINDINGS ==="
cat <<'FINDINGS'
1. Evidence Composition no longer relies on model-authored free-form evidence text.

2. The semantic model remains responsible for selecting bounded project-context
   evidence references within the existing single Ollama invocation.

3. The runtime deterministically validates that every selected evidence reference
   was supplied to the same invocation.

4. The runtime, not the model, attaches the exact repository excerpt associated
   with the validated source identity.

5. Source excerpt presentation therefore does not require deterministic semantic
   comparison between model-authored prose and repository evidence.

6. Non-null evidence with zero sources fails closed.

7. Unsupplied evidence sources fail closed.

8. Duplicate evidence sources are removed deterministically.

9. Conversation-turn evidence remains outside this implementation unit and no
   new semantics for assistant claims were introduced.

10. Overall supportSourceReferences retain their existing provenance role.

11. evidenceSufficient retains its existing derivation from validated overall
    supportSourceReferences.

12. Reply and durableInterpretation remain independently authored structured
    artifacts.

13. One user message -> one workflow -> one Ollama invocation remains preserved.

14. No persistence, API, client, Living Draft, Approval, Delegation, Envelope,
    or Execution architecture was changed.

15. Structural validation is green.

16. The response-contract guard is green.

17. Live behavioral validation returned:
    SOURCE_EXCERPT_FIRST_LIVE_SUPPORTED

Classification:

EVIDENCE_COMPOSITION_CLOSED

Next Response Composition corridor:

BOUNDARY_COMPOSITION
FINDINGS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "EVIDENCE_COMPOSITION_CLOSED"
