#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== STRUCTURED EVIDENCE ARTIFACT — CONTRACT INVESTIGATION ==="

echo
echo "=== CURRENT STRUCTURED RESPONSE CONTRACT ==="
sed -n '1,190p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT RESPONSE PARSER + VALIDATION ==="
sed -n '90,180p' scripts/utils/ollamaChat.ts
sed -n '430,560p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT SUPPORT PROVENANCE TESTS ==="
sed -n '1,360p' scripts/utils/ollamaChat.support-source-references.test.ts
sed -n '1,220p' scripts/utils/ollamaChat.support-source-production.test.ts

echo
echo "=== CURRENT RESPONSE CONSUMPTION ==="
sed -n '145,320p' server/matilda-chat-workflow.ts
sed -n '35,70p' client/src/matilda-chat/matildaChatApi.ts
sed -n '70,95p' client/src/matilda-chat/MatildaChatWorkspace.tsx

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Evidence Composition prompt-only enforcement failed three live behavioral
validations and has been abandoned.

The alternative architecture investigation classified the next architectural
class as:

STRUCTURED_SAME_INVOCATION_READY

Investigate the smallest safe structured evidence artifact contract.

The artifact must:

1. Be authored by Matilda in the SAME Ollama invocation as reply and
   durableInterpretation.

2. Contain only user-visible evidence content, not hidden reasoning.

3. Carry explicit support references that can be deterministically validated
   against the exact sources supplied to that invocation.

4. Fail closed when it references a source not supplied to the invocation.

5. Prevent a prior assistant conclusion from serving as independent proof of
   itself.

6. Preserve supportSourceReferences as provenance for the overall reply rather
   than changing its existing responsibility.

7. Preserve reply as the primary conversational response.

8. Preserve durableInterpretation as the independently authored durable artifact.

9. Preserve:
   one user message
   -> one workflow
   -> one Ollama invocation
   -> one IEL entry
   -> one conversation turn.

10. Avoid requiring a client/API contract change in the FIRST implementation
    unit if the artifact can initially be validated internally.

Evaluate:

A.
evidence: {
  text: string;
  supportSourceReferences: MatildaSupportSourceReference[];
} | null

B.
evidenceItems: Array<{
  text: string;
  supportSourceReferences: MatildaSupportSourceReference[];
}>

C.
evidenceText: string
evidenceSupportSourceReferences: MatildaSupportSourceReference[]

For each determine:

- semantic clarity
- deterministic validation simplicity
- parser compatibility
- empty/no-evidence behavior
- claim-to-source explicitness
- inventory risk
- validation-before-display feasibility
- persistence implications
- API implications
- preservation of architectural invariants

Also determine whether the first implementation unit should be:

1. schema + parser + types only
2. schema + parser + deterministic validation
3. additionally persist the artifact
4. additionally surface the artifact

Return exactly one:

STRUCTURED_EVIDENCE_OBJECT_READY
STRUCTURED_EVIDENCE_ITEMS_READY
STRUCTURED_EVIDENCE_SPLIT_FIELDS_READY
STRUCTURED_EVIDENCE_CONTRACT_NOT_READY

Then identify exactly one smallest implementation unit.

Do not implement.
Do not change runtime behavior.
Do not modify the client/API.
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
