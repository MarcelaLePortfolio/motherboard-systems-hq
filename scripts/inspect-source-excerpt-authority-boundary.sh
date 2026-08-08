#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SOURCE-EXCERPT AUTHORITY BOUNDARY INVESTIGATION ==="
echo

echo "=== AUTHORITY MODEL REFERENCES ==="
rg -n -C 6 \
'Interpretation Authority|Authority|durableInterpretation|Living Draft|Approval|semantic' \
server scripts docs || true

echo
echo "=== CURRENT EVIDENCE ARTIFACT ==="
rg -n -C 6 \
'interface MatildaEvidenceArtifact|evidence:' \
scripts/utils/ollamaChat.ts

echo
cat <<'QUESTION'
Candidate C proposes replacing model-authored evidence text with
workflow-reproduced repository excerpts that have already been supplied
and validated.

Determine:

1. Is reproducing supplied repository excerpts a deterministic
   presentation operation or a semantic interpretation?

2. Does such an artifact create a second Interpretation Authority?

3. Does any existing architectural invariant prohibit a workflow-owned
   evidence presentation artifact?

4. Would the workflow merely preserve evidence already supplied to the
   model, or would it be generating new semantic content?

5. Is there any repository evidence that this would conflict with the
   Conversation -> IEL -> Living Draft ownership model?

Return exactly one conclusion:

SOURCE_EXCERPT_AUTHORITY_SAFE
or
SOURCE_EXCERPT_AUTHORITY_NOT_SAFE

If NOT_SAFE, identify the precise invariant violated.

Do not implement.
Do not redesign the architecture.
Use repository evidence only.
QUESTION
