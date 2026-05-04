#!/usr/bin/env bash
set -euo pipefail

echo "=== Guidance UI references ==="
grep -R "GuidancePanel\|guidance\|/api/guidance\|operator-guidance" -n app components src server 2>/dev/null | head -160 || true

echo
echo "=== GuidancePanel if present ==="
if [ -f app/components/GuidancePanel.tsx ]; then
  nl -ba app/components/GuidancePanel.tsx | sed -n '1,220p'
fi

echo
echo "=== dashboard/page candidates ==="
find app -maxdepth 3 -type f \( -name "page.tsx" -o -name "*.tsx" \) | sort | sed -n '1,120p'

echo
echo "=== git status ==="
git status --short
