#!/bin/bash
set -euo pipefail

echo "=== api/tasks pollers ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/tasks' public/js public | head -n 20 || true

echo
echo "=== api/runs pollers ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/runs' public/js public | head -n 20 || true

echo
echo "=== diagnostics/system-health pollers ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/diagnostics/system-health' public/js public | head -n 20 || true

echo
echo "=== api/guidance pollers ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git '/api/guidance' public/js public | head -n 20 || true

echo
echo "=== interval usage (trimmed) ==="
grep -Rni --exclude-dir=node_modules --exclude-dir=.git 'setInterval\(' public/js public | head -n 40 || true
