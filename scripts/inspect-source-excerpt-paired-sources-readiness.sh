#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SOURCE-EXCERPT PAIRED-SOURCES READINESS ==="

echo
echo "=== SOURCE TYPES AND EXACT AVAILABLE CONTENT ==="
rg -n -C 8 \
'OllamaChatHistoryTurn|OllamaChatProjectContextExcerpt|userMessage|assistantReply|excerpt:' \
scripts/utils/ollamaChat.ts \
server/matilda-chat-workflow.ts

echo
echo "=== ALL EVIDENCE CONSUMERS ==="
rg -n \
'\.evidence\b|evidence:|MatildaEvidenceArtifact|supportSourceReferences|evidenceSufficient' \
--glob='*.ts' \
--glob='*.tsx' \
--glob='*.sh' \
scripts server routes db \
|| true

echo
echo "=== CURRENT FIXTURES REQUIRING EVIDENCE SHAPE ==="
rg -n -C 5 \
'evidence: (null|\{)|"evidence"|MatildaEvidenceArtifact' \
scripts/utils/*.test.ts \
|| true

echo
echo "=== DETERMINISTIC MATCHING QUESTION ==="
cat <<'QUESTION'
Using only the repository evidence printed above, determine whether the paired
source shape is ready for the smallest internal implementation:

evidence: {
  sources: Array<{
    reference: MatildaSupportSourceReference;
    excerpt: string;
  }>;
} | null

A READY determination requires all of the following to be directly supported:

1. Project-context references can map to the exact supplied excerpt by
   relativePath + lineNumber.

2. Exact equality can validate the reproduced project-context excerpt.

3. Pairing reference + excerpt in the same object avoids positional
   correspondence between parallel arrays.

4. Duplicate pairs can be deterministically removed using the existing source
   identity key.

5. The first implementation can be restricted to project-context excerpts so
   conversation-turn userMessage/assistantReply semantics do not need to be
   decided yet.

6. The artifact can remain internal to ollamaChat for the first implementation
   unit.

7. No current workflow/API/client consumer requires evidence.text.

8. Removing evidence.text from the model output contract would require fixture
   migration, but does not require backward-compatible runtime handling if all
   repository-controlled fixtures and schema expectations are migrated together.

Return exactly one classification:

SOURCE_EXCERPT_PAIRED_SOURCES_READY
or
SOURCE_EXCERPT_CONTRACT_NOT_READY

If READY, identify exactly one smallest implementation unit.
If NOT_READY, identify exactly one unresolved repository-supported blocker.

Do not implement.
Do not modify runtime behavior.
Do not modify persistence.
Do not modify API/client contracts.
Do not decide conversation-turn evidence semantics.
Do not begin Boundary Composition.
Do not begin Adaptive Detail Selection.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
