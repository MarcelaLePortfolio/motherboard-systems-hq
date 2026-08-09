#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== FINALIZE EVIDENCE COMPOSITION CLOSURE ==="

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
echo "=== SUPPORT-DRIVEN LIVE VALIDATION ==="
set +e
live_output="$(
  npx tsx scripts/validate-support-driven-source-excerpt-live.ts 2>&1
)"
live_rc=$?
set -e

printf '%s\n' "$live_output"
echo "LIVE_EXIT_CODE=$live_rc"

if [[ $live_rc -ne 0 ]]; then
  echo "EVIDENCE_COMPOSITION_NOT_CLOSED"
  exit 1
fi

if ! grep -q \
  "SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_SUPPORTED" \
  <<<"$live_output"
then
  echo "EVIDENCE_COMPOSITION_NOT_CLOSED"
  exit 1
fi

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== CLOSURE FINDINGS ==="
cat <<'FINDINGS'
EVIDENCE_COMPOSITION_CLOSED

Verified:

1. supportSourceReferences remains the semantic model's bounded support-provenance
   selection for the reply.

2. Validated project_context_excerpt support references deterministically produce
   Source-Excerpt evidence.

3. Runtime attaches the exact already-supplied repository excerpt.

4. Evidence Composition no longer depends on a separately model-authored
   evidence-selection decision.

5. Model-authored free-form evidence text is not used.

6. Conversation-turn support remains valid provenance but does not create
   Source-Excerpt evidence in this implementation unit.

7. Unsupplied support references fail closed.

8. Duplicate support references are deterministically deduplicated before
   evidence construction.

9. Empty validated support produces null evidence.

10. evidenceSufficient retains its established derivation from validated
    supportSourceReferences.

11. Matilda remains the semantic and Interpretation Authority.

12. Deterministic workflow code performs evidence presentation only and does not
    author semantic claims.

13. One user message -> one workflow -> one Ollama invocation remains preserved.

14. Reply and durableInterpretation remain independently authored.

15. No persistence, API, client, Living Draft, Approval, Delegation, Envelope,
    or Execution architecture was changed.

16. Structural tests pass.

17. Response-contract guard passes.

18. Live validation returns:
    SUPPORT_DRIVEN_SOURCE_EXCERPT_LIVE_SUPPORTED

Classification:

EVIDENCE_COMPOSITION_CLOSED

Next canonical Response Composition corridor:

BOUNDARY_COMPOSITION
FINDINGS

echo
echo "EVIDENCE_COMPOSITION_CLOSED"
