#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("server/delegation/production-delegation-consumer.ts")
text = path.read_text()

old = '"../../db/governance-runtime.js"'
new = '"../../db/governance-runtime"'

if old not in text:
    raise SystemExit("AUTHORIZED_IMPORT_PATTERN_NOT_FOUND")

path.write_text(text.replace(old, new, 1))
PY

npx tsc --noEmit --pretty false
git diff --check

git add server/delegation/production-delegation-consumer.ts
git commit -m "Fix delegation consumer governance runtime import"
git push

rm -f /tmp/motherboard-express-dev.log
nohup npm run dev > /tmp/motherboard-express-dev.log 2>&1 &
echo $! > /tmp/motherboard-express-dev.pid

for _ in 1 2 3 4 5; do
  if curl -sS http://localhost:3000/api/projects/registry >/tmp/project-registry-second-fix.json 2>/dev/null; then
    break
  fi
  sleep 1
done

echo "=== EXPRESS PROCESS ==="
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
tail -n 100 /tmp/motherboard-express-dev.log 2>/dev/null || true
