#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SOURCE-EXCERPT-FIRST — ARTIFACT CONTRACT INVESTIGATION ==="

echo
echo "=== CURRENT STRUCTURED RESPONSE CONTRACT ==="
sed -n '1,190p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT EVIDENCE PARSER + VALIDATION ==="
sed -n '200,340p' scripts/utils/ollamaChat.ts
sed -n '620,770p' scripts/utils/ollamaChat.ts

echo
echo "=== AVAILABLE SOURCE MATERIAL ==="
sed -n '130,175p' scripts/utils/ollamaChat.ts
sed -n '455,490p' scripts/utils/ollamaChat.ts

echo
echo "=== WORKFLOW CONSUMPTION ==="
sed -n '175,265p' server/matilda-chat-workflow.ts

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Candidate C — Source-Excerpt-First — has passed the authority investigation:

SOURCE_EXCERPT_AUTHORITY_SAFE

The next task is to determine the smallest deterministic artifact contract.
Do not implement it yet.

The artifact must eliminate model-authored evidence text as the source of
evidence presentation and instead reproduce only exact source material that was
already supplied to the invocation and deterministically validated.

Evaluate these candidate shapes:

A.
evidence: {
  supportSourceReferences: MatildaSupportSourceReference[];
  sourceExcerpts: string[];
} | null

B.
evidence: {
  sources: Array<{
    reference: MatildaSupportSourceReference;
    excerpt: string;
  }>;
} | null

C.
evidenceSources: Array<{
  reference: MatildaSupportSourceReference;
  excerpt: string;
}>

For each determine:

1. Can every excerpt be deterministically matched to exactly one supplied source?

2. Does the shape preserve the relationship between source identity and source
   content without relying on array-order conventions?

3. Can conversation-turn sources and project-context sources both be represented
   without inventing new semantic content?

4. For conversation-turn evidence, what exact source material is eligible:
   - userMessage only;
   - assistantReply only;
   - both as separate fields;
   - or should conversation-turn excerpts be excluded from the first
     implementation unit because assistant replies are claims rather than
     independent evidence?

5. Does the shape remove the semantic-correspondence problem demonstrated by
   Candidate A?

6. Can deterministic validation require exact equality between artifact content
   and the source material supplied in the invocation?

7. Can duplicate evidence sources be removed deterministically?

8. Is null versus empty evidence behavior unambiguous?

9. Can the first implementation remain internal to ollamaChat without:
   - persistence changes;
   - API changes;
   - client changes;
   - another model invocation?

10. Should the existing model-authored evidence.text field be:
    - removed immediately;
    - temporarily retained but ignored;
    - or replaced only after a compatibility investigation?

11. Does changing the current required evidence schema require fixture migration
    or backward-compatibility handling?

12. What is the smallest implementation unit that can prove the deterministic
    Source-Excerpt-First contract without surfacing it to the user?

Return exactly one classification:

SOURCE_EXCERPT_PAIRED_SOURCES_READY
SOURCE_EXCERPT_PARALLEL_ARRAYS_READY
SOURCE_EXCERPT_TOP_LEVEL_ARRAY_READY
SOURCE_EXCERPT_CONTRACT_NOT_READY

Then identify exactly one smallest implementation unit.

Do not implement.
Do not persist the artifact.
Do not modify API/client contracts.
Do not retry Candidate A.
Do not begin Boundary Composition.
Do not begin Adaptive Detail Selection.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
