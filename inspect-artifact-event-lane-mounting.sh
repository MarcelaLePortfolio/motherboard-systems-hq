
#!/usr/bin/env bash

set -euo pipefail

echo "--- server artifact attach imports / calls ---"

git grep -nE "attachArtifacts|emitArtifact|server/artifacts|artifacts.mjs" -- server.mjs server scripts ':!*.txt' ':!*.md' || true

echo

echo "--- server.mjs route mount area ---"

sed -n '1,220p' server.mjs

echo

echo "--- project visual output consumer exact behavior ---"

sed -n '1,160p' public/js/project-visual-output.js

echo

echo "--- project visual output mounted or hidden ---"

grep -nE "project-visual-output|phase59-compat-roots|hidden|aria-hidden" public/index.html public/dashboard.html || true

echo

echo "--- bundle entrypoint includes project visual output? ---"

git grep -n "project-visual-output" -- public/js public/index.html public/dashboard.html ':!public/bundle.js' ':!public/bundle.js.map' || true

