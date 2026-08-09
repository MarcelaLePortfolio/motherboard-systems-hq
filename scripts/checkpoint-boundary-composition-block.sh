#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION CHECKPOINT ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo
echo "Expected HEAD: abf209d1"
echo "Expected status: clean"
echo
echo "Run DR only if this checkpoint matches."
