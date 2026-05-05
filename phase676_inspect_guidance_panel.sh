#!/usr/bin/env bash
set -euo pipefail

TARGET="app/components/GuidancePanel.tsx"

echo "=== Target ==="
echo "$TARGET"

echo ""
echo "=== Backup ==="
cp "$TARGET" "$TARGET.bak_phase676_pre_coherence_ui"

echo ""
echo "=== First 380 lines ==="
sed -n '1,380p' "$TARGET"

echo ""
echo "=== Backup created ==="
ls -lh "$TARGET.bak_phase676_pre_coherence_ui"
