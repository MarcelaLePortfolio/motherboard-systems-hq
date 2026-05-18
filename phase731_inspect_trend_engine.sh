
#!/bin/bash

set -euo pipefail

TARGET="scripts/semantic-observability/generate-semantic-trend-analysis.sh"

echo "== PHASE 731 TREND ENGINE INSPECTION =="

echo

echo "Target:"

echo "$TARGET"

echo

echo "File metadata:"

ls -lah "$TARGET"

echo

echo "Line count:"

wc -l "$TARGET"

echo

echo "Functions:"

grep -n "^.*() {" "$TARGET" || true

echo

echo "Rolling window references:"

grep -nEi "rolling|window|variance|confidence|micro|drift|trend" "$TARGET" || true

echo

echo "Full source snapshot:"

sed -n '1,260p' "$TARGET"

