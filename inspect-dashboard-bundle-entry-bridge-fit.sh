
#!/usr/bin/env bash

set -euo pipefail

echo "--- dashboard-bundle-entry imports ---"

nl -ba public/js/dashboard-bundle-entry.js

echo

echo "--- served dashboard bundle entry mount ---"

grep -nE 'dashboard-bundle-entry|dashboard-delegation|project-visual-output|observational-panels|recent-tasks-card|task-events-card|operator-guidance-panel' public/dashboard.html || true

echo

echo "--- modules currently imported by dashboard-bundle-entry exist ---"

while read -r line; do

  mod="$(printf '%s\n' "$line" | sed -nE 's/^import "\.\/([^"]+)";/\1/p')"

  [ -z "$mod" ] && continue

  [ -f "public/js/$mod" ] && echo "OK public/js/$mod" || echo "MISSING public/js/$mod"

done < public/js/dashboard-bundle-entry.js

echo

echo "--- candidate planning preview module name availability ---"

ls -lah public/js/planning-preview-card.js 2>/dev/null || echo "available: public/js/planning-preview-card.js"

echo

echo "--- current git head ---"

git log --oneline -5

