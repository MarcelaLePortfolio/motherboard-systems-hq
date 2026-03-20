#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "== agent-status-row source =="
sed -n '1,220p' public/js/agent-status-row.js

echo
echo "== dashboard bundle matches agent row =="
grep -n 'indicator.bar.style.background\|indicator.bar.style.width\|agent-status-container\|applyVisual' public/bundle.js || true

echo
echo "== dashboard html agent container anchors =="
grep -n 'agent-status-container\|agent-status-row\|agent-row' public/dashboard.html || true
