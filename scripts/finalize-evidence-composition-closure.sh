#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== FINALIZE EVIDENCE COMPOSITION CLOSURE ==="

echo
echo "=== STRUCTURAL VALIDATION ==="
npx tsx --test \
  server/matilda-evidence-request-signal.test.ts \
  server/matilda-explanation-request-signal.test.ts \
  scripts/utils/ollamaChat.explicit-evidence-request-context.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.evidence-sufficiency-gate.test.ts \
  scripts/utils/ollamaChat.reasoning-composition.test.ts \
  scripts/utils/ollamaChat.summary-composition.test.ts \
  scripts/utils/ollamaChat.test.ts

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== REPEATED LIVE VALIDATION ==="
python3 scripts/validate-explicit-evidence-request-live-repeat.py

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "=== CLOSURE DETERMINATION ==="
cat <<'FINDINGS'
EVIDENCE_COMPOSITION_CLOSED

Verified:

1. Explicit repository-evidence requests are classified by a dedicated bounded
   deterministic Evidence Request Signal.

2. The existing Explanation Request Signal remains unchanged in ownership and
   semantics.

3. Project-context retrieval still occurs before the single Ollama invocation.

4. Matilda remains the semantic and Interpretation Authority for the reply.

5. No second semantic author or second model invocation was introduced.

6. supportSourceReferences retains its existing role as model-selected support
   provenance.

7. evidenceSufficient retains its existing derivation from validated
   supportSourceReferences.

8. For ordinary interactions, project-context Source-Excerpt evidence continues
   to derive from validated project-context support references.

9. For explicit repository-evidence requests, exact project-context excerpts
   already supplied to the invocation are deterministically surfaced as
   Source-Excerpt evidence.

10. Deterministic evidence presentation does not author new semantic claims,
    paraphrases, justification, or free-form evidence text.

11. Unsupplied project-context references continue to fail closed.

12. Duplicate support references remain deterministically deduplicated.

13. Empty retrieved project context produces no deterministic Source-Excerpt
    artifact.

14. The structured Ollama response contract remains intact.

15. reply and durableInterpretation remain distinct independently authored
    artifacts.

16. One user message -> one workflow -> one Ollama invocation remains preserved.

17. Structural validation passes.

18. Response-contract guard passes.

19. Repeated live validation passes 3/3 against the explicit repository-evidence
    scenario that previously produced nondeterministic null evidence.

Classification:

EVIDENCE_COMPOSITION_CLOSED

Next canonical Response Composition corridor:

BOUNDARY_COMPOSITION
FINDINGS

echo
echo "EVIDENCE_COMPOSITION_CLOSED"
