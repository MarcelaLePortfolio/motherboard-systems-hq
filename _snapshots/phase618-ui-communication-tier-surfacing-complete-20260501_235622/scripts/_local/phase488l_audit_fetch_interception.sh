#!/bin/bash
set -euo pipefail

echo "=== FETCH OVERRIDES (trimmed) ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  'window\.fetch\s*=|globalThis\.fetch\s*=|fetch\s*=|serviceWorker|navigator\.serviceWorker' \
  public server routes . | head -n 40 || true

echo
echo "=== /api/chat REFERENCES (trimmed) ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/chat' \
  public server routes . | head -n 40 || true
