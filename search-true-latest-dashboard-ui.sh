
#!/usr/bin/env bash

set -euo pipefail

echo "===== TRUE LATEST DASHBOARD UI SEARCH ====="

date

echo

echo "===== CURRENT STABLE BASELINE ====="

git log --oneline -8

echo

echo "===== SEARCH ALL GIT BRANCHES/TAGS FOR DASHBOARD UI COMMITS ====="

git log --oneline --all --decorate --date=iso \

  -- public/index.html public/dashboard.html public/js public/bundle.js \

  | head -250

echo

echo "===== SEARCH REFLOG FOR DASHBOARD/UI RESTORE HISTORY ====="

git reflog --all --date=iso \

  | grep -Ei 'dashboard|phase7|phase74|ui|bridge|restore|preview|artifact|latest' \

  | head -250 || true

echo

echo "===== SEARCH RIO DRIVE FOR HIGH-SIGNAL DASHBOARD NAMES ====="

find "/Volumes/Rio Drive" -type f 2>/dev/null \

  \( -iname '*dashboard*.html' -o -iname '*index.html' -o -iname '*phase530*bridge*.js' -o -iname '*visible*panel*.js' \) \

  -print0 \

  | xargs -0 stat -f "%m %z %N" 2>/dev/null \

  | sort -nr \

  | head -300

echo

echo "===== SEARCH DOCKER IMAGE HISTORY ====="

docker images --format '{{.Repository}}:{{.Tag}} {{.ID}} {{.CreatedAt}} {{.Size}}' | grep -Ei 'motherboard|dashboard' || true

echo

echo "===== DONE ====="

echo "No files were changed."

