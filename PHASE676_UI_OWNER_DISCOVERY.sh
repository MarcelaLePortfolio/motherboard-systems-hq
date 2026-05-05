#!/usr/bin/env bash
set -euo pipefail

echo "=== Locate Guidance UI Components ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git \
  -E "Guidance|guidance|operatorGuidance|GuidancePanel" \
  dashboard app 2>/dev/null || true

echo ""
echo "=== Locate API Usage in UI ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git \
  -E "/api/guidance|guidance-history|operator-guidance" \
  dashboard app 2>/dev/null || true

echo ""
echo "=== Likely Panel Files ==="
find dashboard app -type f \( -name "*Guidance*.tsx" -o -name "*Guidance*.ts" -o -name "*guidance*.tsx" -o -name "*guidance*.ts" \) 2>/dev/null || true

echo ""
echo "=== Next Step ==="
echo "Identify the exact component rendering guidance before applying any UI patch."
