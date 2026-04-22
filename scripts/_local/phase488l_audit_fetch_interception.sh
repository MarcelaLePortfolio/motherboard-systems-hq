#!/bin/bash
set -euo pipefail

echo "=== SEARCH FOR FETCH OVERRIDES / INTERCEPTORS ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
  'window\.fetch\s*=|globalThis\.fetch\s*=|fetch\s*=|const fetch =|let fetch =|function fetch\(|serviceWorker|navigator\.serviceWorker|XMLHttpRequest|proxy.*fetch|intercept.*fetch' \
  public server routes . | head -n 200 || true

echo
echo "=== SEARCH FOR /api/chat REFERENCES OUTSIDE MATILDA CONSOLE ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/chat' public server routes . | head -n 200 || true
