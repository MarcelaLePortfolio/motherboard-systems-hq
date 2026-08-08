#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SOURCE-EXCERPT-FIRST ARTIFACT INVESTIGATION ==="
echo

echo "=== CURRENT ARCHITECTURAL BASELINE ==="
git log --oneline -5
echo
git status --short
echo

echo "=== EXISTING STRUCTURED EVIDENCE CONTRACT ==="
rg -n -C 8 \
'MatildaEvidenceArtifact|supportSourceReferences|evidence:' \
scripts/utils/ollamaChat.ts

echo
echo "=== INVESTIGATION ==="

cat <<'QUESTION'
Candidate A has been shown to be structurally correct but unable to
deterministically prove semantic correspondence between model-authored
evidence text and repository evidence.

Investigate Candidate C only.

Candidate C:

evidence {
    supportSourceReferences:[...]
    sourceExcerpts:[...]
}

where sourceExcerpts are reproduced directly from the already validated,
already supplied repository evidence.

Determine:

1. Does reproducing validated repository excerpts constitute semantic
   interpretation, or deterministic evidence presentation?

2. Does this preserve Matilda as the sole Interpretation Authority?

3. Can the workflow construct this artifact without another Ollama call?

4. Does this eliminate the semantic-correspondence problem discovered in
   Candidate A?

5. Does this preserve Evidence Sufficiency?

6. Does this preserve Support Provenance?

7. Does this require any ontology?

8. Does this require client changes?

Return exactly one conclusion:

SOURCE_EXCERPT_FIRST_READY
or
SOURCE_EXCERPT_FIRST_NOT_SAFE

If NOT_SAFE, identify the exact architectural invariant violated.

Do not implement.
Do not modify runtime.
Do not propose prompt changes.
QUESTION
