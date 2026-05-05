#!/usr/bin/env bash
set -euo pipefail

echo "Inspecting status UI components..."

echo
echo "=== app/components/ui/StatusRow.tsx ==="
sed -n '1,180p' app/components/ui/StatusRow.tsx

echo
echo "=== app/components/SubsystemStatusPanel.tsx ==="
sed -n '1,180p' app/components/SubsystemStatusPanel.tsx

echo
echo "=== app/components/GuidancePanel.tsx status area ==="
sed -n '340,410p' app/components/GuidancePanel.tsx

git add PHASE702_STEP5B_INSPECT_STATUS_COMPONENTS.sh
git commit -m "Phase 702: inspect status UI components"
git push

git status --short
