#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("server/routes/governance-delegation-route.ts")
text = path.read_text()

text = text.replace(
    '"../delegation/production-delegation-consumer.js"',
    '"../delegation/production-delegation-consumer"',
    1,
)
text = text.replace(
    '"../delegation/production-delegation-entry-point.js"',
    '"../delegation/production-delegation-entry-point"',
    1,
)

path.write_text(text)
PY

npx tsc --noEmit --pretty false
git diff --check

git add server/routes/governance-delegation-route.ts
git commit -m "Fix delegation route source import resolution"
git push

rm -f /tmp/motherboard-express-dev.log
nohup npm run dev > /tmp/motherboard-express-dev.log 2>&1 &
echo $! > /tmp/motherboard-express-dev.pid

for _ in 1 2 3 4 5; do
  if curl -sS http://localhost:3000/api/projects/registry >/tmp/project-registry-after-fix.json 2>/dev/null; then
    break
  fi
  sleep 1
done

echo "=== SERVER PROCESS ==="
lsof -nP -iTCP:3000 -sTCP:LISTEN || true

echo "=== DIRECT REGISTRY ==="
curl -sS -w '\nHTTP_STATUS=%{http_code}\n' \
  http://localhost:3000/api/projects/registry || true

echo "=== VITE 5173 REGISTRY ==="
curl -sS -w '\nHTTP_STATUS=%{http_code}\n' \
  http://localhost:5173/api/projects/registry || true

echo "=== VITE 5174 REGISTRY ==="
curl -sS -w '\nHTTP_STATUS=%{http_code}\n' \
  http://localhost:5174/api/projects/registry || true

echo "=== SERVER LOG ==="
tail -n 80 /tmp/motherboard-express-dev.log 2>/dev/null || true
