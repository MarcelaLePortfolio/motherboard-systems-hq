#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== DETERMINE NEXT RESPONSE COMPOSITION CORRIDOR ==="

EXPECTED_HEAD="69a26c73"

if [[ "$(git rev-parse --short HEAD)" != "$EXPECTED_HEAD" ]]; then
  echo "STOP: HEAD no longer matches Adaptive Detail closure checkpoint $EXPECTED_HEAD."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/determine-next-response-composition-corridor\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== ADAPTIVE DETAIL CLOSURE ==="
grep -n -C 8 \
  -E 'ADAPTIVE_DETAIL_SELECTION_COMPLETE|NEXT_ACTION=DETERMINE_NEXT_RESPONSE_COMPOSITION_CORRIDOR|Deferred successor corridor' \
  scripts/validate-adaptive-detail-corridor-closure.sh

echo
echo "=== PHASE 1 RESPONSE COMPOSITION REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='determine-next-response-composition-corridor.sh' \
  -Ei 'Phase 1 Response Composition|Summary Composition|Reasoning Classification|Reasoning Composition|Evidence Composition|Boundary Composition|Adaptive Detail Selection|Response Composition' \
  docs scripts server 2>/dev/null || true

echo
echo "=== CORRIDOR CLOSURE / CAPABILITY REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='determine-next-response-composition-corridor.sh' \
  -Ei 'SUMMARY.*COMPLETE|REASONING.*COMPLETE|EVIDENCE.*COMPLETE|BOUNDARY.*COMPLETE|ADAPTIVE_DETAIL.*COMPLETE|corridor.*closed|closure.*validated|IMPLEMENTED|NOT_IMPLEMENTED|NOT_STARTED' \
  docs scripts 2>/dev/null || true

echo
echo "=== RESPONSE-COMPOSITION CONTRACT TESTS ==="
find scripts/utils -maxdepth 1 -type f \
  \( \
    -name 'ollamaChat.summary-composition.test.ts' -o \
    -name 'ollamaChat.reasoning-composition.test.ts' -o \
    -name 'ollamaChat.boundary-composition.test.ts' -o \
    -name 'ollamaChat.explanation-status.test.ts' -o \
    -name 'ollamaChat.structured-evidence-object.test.ts' \
  \) \
  -print \
  | sort

echo
echo "=== RECENT RESPONSE-COMPOSITION HISTORY ==="
git log \
  --oneline \
  --decorate \
  --all \
  --grep='Summary Composition\|Reasoning\|Evidence Composition\|Boundary Composition\|Adaptive Detail' \
  -n 80

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== DETERMINATION ==="
cat <<'FINDINGS'
Determine the next Response Composition corridor from repository evidence only.

Known Phase 1 sequence:

1. Summary Composition
2. Reasoning Classification / Reasoning Composition
3. Evidence Composition
4. Boundary Composition
5. Adaptive Detail Selection

Adaptive Detail Selection is now closed.

The determination must establish for every Phase 1 corridor:

A. whether it is:
   - implemented and closed;
   - implemented but closure not established;
   - partially implemented;
   - characterized only;
   - absent;

B. the repository evidence supporting that classification;

C. whether any corridor that appears earlier in the sequence still has an
   unresolved closure obligation;

D. whether Phase 1 Response Composition itself is now complete;

E. if Phase 1 is complete, whether the next canonical milestone is Phase 2
   Investigation Lifecycle;

F. whether CONVERSATION_ENGINE_GENERATION_STABILITY remains deferred and must
   not displace the canonical Matilda Collaboration Runtime sequence.

Required final classification:

Exactly one of:

NEXT_RESPONSE_COMPOSITION_CORRIDOR_SUMMARY_COMPOSITION
NEXT_RESPONSE_COMPOSITION_CORRIDOR_REASONING_CLASSIFICATION
NEXT_RESPONSE_COMPOSITION_CORRIDOR_EVIDENCE_COMPOSITION
NEXT_RESPONSE_COMPOSITION_CORRIDOR_BOUNDARY_COMPOSITION
PHASE_1_RESPONSE_COMPOSITION_COMPLETE
RESPONSE_COMPOSITION_SEQUENCE_REQUIRES_RECONCILIATION

If:

PHASE_1_RESPONSE_COMPOSITION_COMPLETE

then identify the next canonical phase as:

PHASE_2_INVESTIGATION_LIFECYCLE

unless repository evidence contradicts that sequence.

Do not implement.

Do not alter runtime.

Do not alter prompts.

Do not change model parameters.

Do not add retries.

Do not add another model invocation.

Do not reopen Adaptive Detail.

Do not reopen Boundary Composition without contradictory evidence.

Do not pull CONVERSATION_ENGINE_GENERATION_STABILITY into the active canonical
corridor merely because it is deferred.

Preserve Matilda as Interpretation Authority.
FINDINGS

echo
echo "=== VERIFY PRODUCTION RUNTIME UNCHANGED ==="
if ! git diff --quiet -- \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts
then
  echo "STOP: production runtime changed during corridor determination."
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
echo "NEXT_RESPONSE_COMPOSITION_CORRIDOR_EVIDENCE_COLLECTED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_PHASE_1_RESPONSE_COMPOSITION_STATE"

git add scripts/determine-next-response-composition-corridor.sh
git commit -m "Determine next Response Composition corridor"
git push
