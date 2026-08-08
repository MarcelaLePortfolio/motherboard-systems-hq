#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SOURCE-EXCERPT-FIRST — IMPLEMENTATION SURFACE CONFIRMATION ==="

echo
echo "=== TARGET CONTRACT SURFACE ==="
sed -n '20,180p' scripts/utils/ollamaChat.ts

echo
echo "=== TARGET PARSER SURFACE ==="
sed -n '200,340p' scripts/utils/ollamaChat.ts

echo
echo "=== TARGET VALIDATION SURFACE ==="
sed -n '610,765p' scripts/utils/ollamaChat.ts

echo
echo "=== PROJECT-CONTEXT SOURCE MATERIAL ==="
sed -n '130,155p' scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED EVIDENCE TEST SURFACE ==="
sed -n '1,220p' scripts/utils/ollamaChat.structured-evidence-object.test.ts

echo
echo "=== REQUIRED FIXTURE MIGRATION SURFACE ==="
rg -l \
'evidence: (null|\{)|"evidence"' \
scripts/utils/ollamaChat*.test.ts \
| sort

echo
echo "=== IMPLEMENTATION DETERMINATION ==="
cat <<'DETERMINATION'
Classification:

SOURCE_EXCERPT_PAIRED_SOURCES_READY

Smallest candidate implementation unit:

Replace the internal model-authored evidence artifact:

  evidence: {
    text: string;
    supportSourceReferences: MatildaSupportSourceReference[];
  } | null

with the paired Source-Excerpt-First artifact:

  evidence: {
    sources: Array<{
      reference: MatildaSupportSourceReference;
      excerpt: string;
    }>;
  } | null

for project_context_excerpt sources only.

Required deterministic behavior:

1. Every evidence source reference must identify a project-context excerpt
   supplied to the same invocation.

2. The artifact excerpt must exactly equal the supplied excerpt associated with
   relativePath + lineNumber.

3. Conversation-turn references are not admitted into evidence.sources in this
   first implementation unit.

4. Duplicate evidence sources are removed using the existing
   project_context_excerpt:<relativePath>:<lineNumber> identity.

5. Non-null evidence with zero validated sources fails closed.

6. evidence.text is removed rather than retained or interpreted.

7. supportSourceReferences for the overall reply remain unchanged.

8. evidenceSufficient remains derived from validated overall
   supportSourceReferences and is not redefined by the evidence artifact.

9. No persistence, API, client, workflow, or second-model-invocation changes are
   included.

10. Repository-controlled structured-response fixtures migrate atomically to the
    new required evidence shape.

This command confirms the exact implementation surface only.
It does not implement the contract.
DETERMINATION

echo
echo "=== EXECUTION GATE CHECK ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "SOURCE_EXCERPT_FIRST_IMPLEMENTATION_SURFACE_CONFIRMED"
