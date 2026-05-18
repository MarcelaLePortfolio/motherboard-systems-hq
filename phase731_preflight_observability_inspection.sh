
#!/bin/bash

set -euo pipefail

echo "== PHASE 731 PREFLIGHT OBSERVABILITY INSPECTION =="

echo

echo "Current path:"

pwd

echo

echo "Git state:"

git status --short

git branch --show-current

git rev-parse --short HEAD

echo

echo "Locate trend analysis script:"

ls -la generate-semantic-trend-analysis.sh 2>/dev/null || true

find . -maxdepth 4 -name "generate-semantic-trend-analysis.sh" -print

echo

echo "Preview existing trend script header:"

sed -n '1,220p' generate-semantic-trend-analysis.sh 2>/dev/null || true

echo

echo "Relevant existing phase 731 files:"

find . -maxdepth 3 \( -iname "*731*" -o -iname "*trend*analysis*" -o -iname "*confidence*" \) -print | sort | head -80

