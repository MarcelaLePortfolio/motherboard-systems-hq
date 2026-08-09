#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== ADAPTIVE DETAIL — EXCERPT RANGE METADATA EXTENSION CONTRACT ==="

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo "PROTECTED DR: 20260808_231729"

echo
echo "=== RETRIEVAL CONTRACT ==="
sed -n '35,75p' server/matilda-project-context-retrieval.ts

echo
echo "=== BOUNDED EXCERPT IMPLEMENTATION ==="
sed -n '150,195p' server/matilda-project-context-retrieval.ts

echo
echo "=== EXCERPT ASSEMBLY ==="
sed -n '315,360p' server/matilda-project-context-retrieval.ts

echo
echo "=== CONVERSATION CONTEXT PASS-THROUGH ==="
sed -n '35,100p' server/matilda-conversation-context-runtime.ts

echo
echo "=== OLLAMA PROJECT CONTEXT CONTRACT ==="
sed -n '120,165p' scripts/utils/ollamaChat.ts

echo
echo "=== OLLAMA PROJECT CONTEXT SERIALIZATION ==="
sed -n '415,450p' scripts/utils/ollamaChat.ts

echo
echo "=== SUPPORT REFERENCE IDENTITY ==="
sed -n '115,155p' scripts/utils/ollamaChat.ts
sed -n '570,620p' scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED EVIDENCE CONSTRUCTION ==="
sed -n '640,725p' scripts/utils/ollamaChat.ts

echo
echo "=== PROJECT CONTEXT RETRIEVAL TESTS ==="
sed -n '1,280p' server/matilda-project-context-retrieval.test.ts

echo
echo "=== CONVERSATION CONTEXT TESTS ==="
sed -n '1,240p' server/matilda-conversation-context-runtime.test.ts

echo
echo "=== CONTRACT QUESTIONS ==="
cat <<'QUESTIONS'
Determine from repository evidence only:

1. Can exact bounded source coordinates be retained without changing the
   existing public MatildaProjectContextExcerpt object consumed downstream?

2. Should the smallest internal representation be conceptually:

   {
     excerpt: MatildaProjectContextExcerpt,
     sourceRange: {
       startLineNumber,
       endLineNumber
     }
   }

   or can the range safely live as additional internal-only fields on the
   retrieval object without leaking into Ollama context or persisted evidence?

3. Confirm whether startLineNumber and endLineNumber should be 1-based inclusive
   source coordinates.

4. Determine whether endLineNumber may represent the original bounded source
   range when MAX_EXCERPT_CHARACTERS truncates the materialized excerpt before
   that line is fully represented.

5. If not, determine the minimum truncation metadata required to distinguish:

   - complete bounded source range;
   - character-truncated materialized excerpt;
   - truncation ending inside a source line.

6. Determine whether a boolean such as excerptTruncated is sufficient for the
   immediate metadata prerequisite, or whether exact represented end coordinates
   or character offsets are required before deterministic segmentation.

7. Identify the single current owner of start/end computation and confirm that
   no second owner or source-file reread is necessary.

8. Identify the exact tests capable of proving that a metadata-only extension
   leaves unchanged:

   - returned excerpt text;
   - retrieval ranking;
   - candidate admission;
   - MAX_MATCHES behavior;
   - relativePath + lineNumber support identity;
   - supportSourceReferences;
   - evidenceSufficient;
   - Source-Excerpt Evidence Composition;
   - Ollama response schema;
   - one workflow -> one Ollama invocation.

9. Determine the smallest safe implementation surface if and only if repository
   evidence establishes that the metadata extension can remain behaviorally
   inert.

Do not implement the extension in this unit.
Do not implement segmentation.
Do not implement semantic admission.
Do not modify ranking, MAX_MATCHES, or query extraction.
Do not change supportSourceReferences or Evidence Composition.
Do not expose range metadata to the Ollama response schema.
Do not add another model invocation.
Do not perform post-model semantic filtering.
Do not reopen Boundary Composition.
QUESTIONS

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "ADAPTIVE_DETAIL_EXCERPT_RANGE_METADATA_CONTRACT_INSPECTION_COMPLETE"
echo "NEXT_ACTION=DOCUMENT_REPOSITORY_SUPPORTED_FINDINGS"
