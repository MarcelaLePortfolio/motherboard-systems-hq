#!/usr/bin/env bash
set -euo pipefail

echo "=== Express Entry Candidates ==="
find . -maxdepth 4 -type f | sort | grep -E 'server\.mjs|server\.js|index\.mjs|index\.js|app\.mjs|app\.js' || true

echo ""
echo "=== Guidance Route Registrations ==="
grep -RIn --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=_snapshots \
  -E "api/guidance|operator-guidance|guidance-history|routes/api-guidance|server/api/guidance|app\.use|app\.get" \
  server*.mjs server server/routes server/api 2>/dev/null || true

echo ""
echo "=== Current Express Guidance Route Files ==="
for file in server/routes/api-guidance.mjs server/api/guidance.mjs server/api/guidance-history.mjs server/routes/guidance.js server/routes/operator-guidance.mjs server/routes/guidance-sse.js; do
  if [ -f "$file" ]; then
    echo ""
    echo "----- $file -----"
    sed -n '1,240p' "$file"
  fi
done

echo ""
echo "=== Live Route Probe ==="
BASE_URL="${NEXT_PUBLIC_BASE_URL:-http://localhost:3000}"
for path in /api/guidance /api/guidance/history /api/guidance/coherence-shadow /api/guidance/coherence-preview; do
  echo ""
  echo "GET ${BASE_URL}${path}"
  curl -i -sS "${BASE_URL}${path}" | head -30 || true
done
