#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

echo "== branch =="
git branch --show-current

echo
echo "== head =="
git rev-parse --short HEAD
git rev-parse --short origin/phase61-cherry-pick-recovery

echo
echo "== status =="
git status --short

echo
echo "== dashboard port =="
lsof -i :8080 || true

echo
echo "== bounded ops sample =="
curl -N --max-time 8 http://127.0.0.1:8080/events/ops || true
