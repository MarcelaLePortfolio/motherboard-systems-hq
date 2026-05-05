#!/usr/bin/env bash
set -euo pipefail

echo "Inspecting likely chat/runtime UI surface..."

sed -n '1,260p' app/demo-runtime/page.tsx

git add PHASE702_STEP2C_FIND_CHAT_SURFACE.sh PHASE702_STEP2_PATCH_CHAT_LABEL.sh PHASE702_STEP2D_INSPECT_DEMO_RUNTIME_CHAT.sh
git commit -m "Phase 702: add chat surface inspection helpers"
git push

git status --short
