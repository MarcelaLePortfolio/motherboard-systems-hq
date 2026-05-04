#!/usr/bin/env bash
set -euo pipefail

echo "=== GuidancePanel current retry/action area ==="
grep -n "copyAction\|fetchGuidance\|Retry Task\|Copy Action\|SAFE ACTION BUTTONS\|button" app/components/GuidancePanel.tsx || true

echo
echo "=== GuidancePanel full file ==="
nl -ba app/components/GuidancePanel.tsx | sed -n '1,280p'

echo
echo "=== git status ==="
git status --short
