#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE SELECTION AUTHORITY SEAMS ==="

echo
echo "=== SUPPORT SOURCE REFERENCE DEFINITIONS ==="
grep -Rni \
  -E 'supportSourceReferences|support source|support reference|support provenance' \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat*.test.ts \
  server \
  --exclude-dir=node_modules \
  | head -n 240 || true

echo
echo "=== SUPPORT SOURCE PROMPT CONTRACT ==="
grep -n -B 12 -A 30 \
  -E 'supportSourceReferences|support source|support reference' \
  scripts/utils/ollamaChat.ts || true

echo
echo "=== EXPLANATION REQUEST SIGNAL IMPLEMENTATION ==="
grep -Rni \
  -E 'explanationRequest|explanation request|ExplanationRequest|isExplanation|explicit explanation' \
  server \
  scripts \
  --exclude-dir=node_modules \
  | head -n 240 || true

echo
echo "=== EXPLANATION REQUEST SIGNAL SOURCE ==="
for file in \
  server/matilda-explanation-request-signal.ts \
  server/matilda-explanation-request-signal.test.ts
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    cat "$file"
  fi
done

echo
echo "=== EVIDENCE SUFFICIENCY CONTRACT ==="
grep -Rni \
  -E 'evidenceSufficient|priorEvidence|prior evidence' \
  server \
  scripts/utils \
  --exclude-dir=node_modules \
  | head -n 240 || true

echo
echo "=== DECISION TEST ==="
cat <<'DECISION'
Determine from repository evidence only:

1. Does supportSourceReferences explicitly represent sources selected by the
   semantic model as supporting its reply/conclusion/recommendation/assessment?

2. If yes, can validated project_context_excerpt entries from that set be
   transformed deterministically into Source-Excerpt-First evidence by attaching
   their already-supplied exact excerpts, without adding semantic authorship?

3. Is the existing explanation-request signal specifically an explanation
   request classifier, or does its established contract also cover explicit
   requests for evidence/repository proof?

4. Would using that signal for Evidence Composition preserve its existing
   semantics, or would doing so silently broaden its ontology?

5. Does either seam solve the observed case where model-authored evidence is
   null while qualifying project-context support exists?

Return exactly one classification:

SUPPORT_DRIVEN_SOURCE_EXCERPT_READY
DETERMINISTIC_EVIDENCE_REQUEST_SIGNAL_READY
SOURCE_EXCERPT_SELECTION_GAP_NOT_READY

Then identify exactly one smallest next implementation or investigation unit.

Do not implement.
Do not close Evidence Composition.
Do not begin Boundary Composition.
Do not begin Adaptive Detail Selection.
DECISION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
