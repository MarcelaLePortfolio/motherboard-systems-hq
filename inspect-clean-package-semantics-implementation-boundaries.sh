#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT CLEAN PACKAGE SEMANTICS IMPLEMENTATION BOUNDARIES ==="
echo "CURRENT_BASELINE=$(git rev-parse --short HEAD)"
echo "AUTHORIZED_BASELINE=ee2d2495"
echo "FAILED_IMPLEMENTATION_ATTEMPTS=1"
echo "IMPLEMENTATION_AUTHORIZATION_REMAINS_ACTIVE=YES"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== OLLAMA CONTRACT EXACT BOUNDARIES ==="
sed -n '1,240p' scripts/utils/ollamaChat.ts
sed -n '250,390p' scripts/utils/ollamaChat.ts
sed -n '630,740p' scripts/utils/ollamaChat.ts
sed -n '900,960p' scripts/utils/ollamaChat.ts
sed -n '1230,1260p' scripts/utils/ollamaChat.ts

echo
echo "=== IEL EXACT BOUNDARIES ==="
sed -n '1,220p' db/matilda-interpretation-runtime.ts
sed -n '220,420p' db/matilda-interpretation-runtime.ts
sed -n '420,520p' db/matilda-interpretation-runtime.ts

echo
echo "=== WORKFLOW EXACT WRITE BOUNDARY ==="
sed -n '220,315p' server/matilda-chat-workflow.ts

echo
echo "=== DRAFT SYNTHESIS EXACT BOUNDARY ==="
cat db/matilda-draft-synthesis-runtime.ts

echo
echo "=== CLEANNESS CHECK ==="
git diff --check
git status --short

echo
echo "NEXT_ACTION=BUILD_SECOND_IMPLEMENTATION_ATTEMPT_FROM_THESE_EXACT_VERIFIED_SOURCE_BOUNDARIES"
