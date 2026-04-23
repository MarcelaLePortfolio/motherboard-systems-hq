#!/bin/bash
set -u

echo "🔍 Diagnosing runtime startup path..."
echo

echo "1) package.json scripts"
if [ -f package.json ]; then
  sed -n '1,220p' package.json
else
  echo "❌ package.json not found"
fi
echo
echo "------------------------------------------------"

echo "2) Files likely responsible for booting the local server"
for f in server.ts scripts/_local/dev-server.ts scripts/launch-matilda.ts scripts/_local/agent-runtime/launch-matilda.ts; do
  if [ -f "$f" ]; then
    echo "📄 FILE: $f"
    echo "------------------------------------------------"
    sed -n '1,220p' "$f"
    echo
  fi
done

echo "3) PM2 process list (if available)"
pm2 list 2>/dev/null || echo "pm2 not available or no processes found"
echo
echo "------------------------------------------------"

echo "4) Common node processes"
ps aux | grep -E 'node|tsx|ts-node|vite|next' | grep -v grep || true
echo
echo "------------------------------------------------"

echo "5) Listening ports 3000/3001/8080"
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
echo "---"
lsof -nP -iTCP:3001 -sTCP:LISTEN || true
echo "---"
lsof -nP -iTCP:8080 -sTCP:LISTEN || true
echo
echo "✅ Diagnosis complete."
echo "Paste back:"
echo "  - package.json scripts"
echo "  - any startup command that references server.ts or dev-server.ts"
