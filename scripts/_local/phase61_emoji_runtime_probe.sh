#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "== branch / head =="
git branch --show-current
git rev-parse --short HEAD
echo

echo "== served bundle emoji markers =="
curl -s http://127.0.0.1:8080/bundle.js | grep -n "AGENT_EMOJI\|emoji.textContent\|indicator.emoji.textContent" || true
echo

echo "== served dashboard bundle reference =="
curl -s http://127.0.0.1:8080/dashboard | grep -n 'bundle.js\|agent-status-container' || true
echo

echo "== local source renderer markers =="
grep -n "AGENT_EMOJI\|emoji.textContent\|indicator.emoji.textContent" public/js/agent-status-row.js public/bundle.js || true
echo

echo "== conclusion template =="
echo "If served bundle shows emoji markers, code is live and remaining issue is browser/DOM/render-layer."
echo "If served bundle still shows bar-based dot logic, the container is serving an older artifact."
