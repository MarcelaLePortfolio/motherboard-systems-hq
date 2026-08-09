#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INVESTIGATE SCOPED MATILDA — GENERATION CONTROL CONTRACT ==="

if [[ "$(git rev-parse --short HEAD)" != "3d647867" ]]; then
  echo "STOP: HEAD no longer matches generation-control classification checkpoint 3d647867."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/investigate-scoped-matilda-generation-control-contract\.sh$' ||
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
echo "=== OLLAMA CHAT CONTEXT CONTRACT ==="
grep -n -C 12 \
  -E 'export interface OllamaChatContext|interface OllamaChatContext|type OllamaChatContext|priorExplanationEvidenceStatus|projectContextSegmentCandidates|observeValidatedSelectedContextSegments|observeParsedSupportSourceReferences' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== OLLAMA CHAT CALLERS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-scoped-matilda-generation-control-contract.sh' \
  -E 'ollamaChat\(' \
  scripts server routes 2>/dev/null || true

echo
echo "=== CONTEXT CONSTRUCTION AT PRODUCTION WORKFLOW ==="
grep -n -C 18 \
  -E 'ollamaChat\(|projectContextSegmentCandidates|priorExplanationEvidenceStatus|observeValidatedSelectedContextSegments|observeParsedSupportSourceReferences' \
  server/matilda-chat-workflow.ts || true

echo
echo "=== VALIDATION HARNESS CONTEXT USAGE ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'observeValidatedSelectedContextSegments|observeParsedSupportSourceReferences|projectContextSegmentCandidates|priorExplanationEvidenceStatus' \
  scripts/validate-*.ts scripts/capture-*.ts 2>/dev/null || true

echo
echo "=== EXISTING OPTIONAL / VALIDATION-ONLY SEAMS ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-scoped-matilda-generation-control-contract.sh' \
  -Ei 'validation-only|observer|optional.*context|test-only|diagnostic|instrumentation' \
  scripts/utils server docs scripts 2>/dev/null || true

echo
echo "=== GENERATION POLICY / GOVERNANCE REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude='investigate-scoped-matilda-generation-control-contract.sh' \
  -Ei 'generation policy|sampling policy|temperature|top_p|top_k|seed|model parameter|generation option|ollama option|semantic generation' \
  docs scripts server 2>/dev/null || true

echo
echo "=== OLLAMA REQUEST OPTIONS SUPPORT — LOCAL EVIDENCE ==="
ollama --version || true
ollama show gemma3:4b 2>/dev/null | sed -n '1,80p' || true

echo
echo "=== EXISTING REQUEST PAYLOAD ==="
sed -n '607,640p' scripts/utils/ollamaChat.ts

echo
echo "=== CONTRACT QUESTIONS ==="
cat <<'QUESTIONS'
Determine from repository evidence only:

1. Does OllamaChatContext already function as an additive optional per-invocation
   configuration surface?

2. Are its current optional fields semantic inputs, validation observers, or
   both?

3. Would adding a validation-only generationOptions field to OllamaChatContext
   be architecturally analogous to the existing observer seams, or would it
   alter production semantic policy?

4. Can a validation harness call ollamaChat with a request-scoped seed while the
   production workflow remains unchanged?

5. Would that preserve:
   one user message -> one workflow -> one Ollama invocation?

6. Would a fixed seed change Matilda's semantic authority, or only sampling
   reproducibility?

7. Would seeded validation prove production stability?
   Distinguish reproducibility of one diagnostic fixture from reliability of
   unseeded production behavior.

8. Is any repository evidence sufficient to authorize temperature/top_p/top_k
   changes for production?

9. Would any production-wide sampling change require a separate Conversation
   Engine corridor because all semantic artifacts share ollamaChat?

10. Is there any smaller repository-controlled explanation for the intermittent
    :22 provenance output than global sampling policy?

Required classification:

Exactly one of:

MATILDA_SCOPED_GENERATION_CONTROL_READY
MATILDA_VALIDATION_ONLY_GENERATION_CONTROL_READY
MATILDA_GLOBAL_GENERATION_POLICY_REQUIRES_SEPARATE_CORRIDOR
MATILDA_GENERATION_CONTROL_NOT_JUSTIFIED

Do not implement.

Do not modify ollamaChat.ts.

Do not modify the workflow.

Do not modify model parameters.

Do not add retries.

Do not add another model invocation.

Do not change supportSourceReferences.

Do not change selectedContextSegments.

Do not change Evidence Composition.

Do not change evidenceSufficient.

Do not change retrieval, segmentation, or ranking.
QUESTIONS

echo
echo "=== RESPONSE CONTRACT GUARD ==="
bash scripts/guard-ollama-response-contract.sh

echo
echo "=== VERIFY RUNTIME UNCHANGED ==="
if ! git diff --quiet -- scripts/utils/ollamaChat.ts server/matilda-chat-workflow.ts; then
  echo "STOP: production runtime changed during investigation."
  git diff -- scripts/utils/ollamaChat.ts server/matilda-chat-workflow.ts
  exit 2
fi

echo "PRODUCTION_RUNTIME_UNCHANGED"

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "SCOPED_MATILDA_GENERATION_CONTROL_CONTRACT_EVIDENCE_COLLECTED"
echo "IMPLEMENTATION_NOT_STARTED"
echo "NEXT_ACTION=CLASSIFY_SCOPED_GENERATION_CONTROL_FROM_REPOSITORY_EVIDENCE"

git add scripts/investigate-scoped-matilda-generation-control-contract.sh
git commit -m "Investigate scoped Matilda generation control contract"
git push
