#!/bin/bash
set -euo pipefail

echo "=== SAFE TAG EXECUTION ==="

if git rev-parse phase488_matilda_stable >/dev/null 2>&1; then
  echo "Tag already exists locally."
else
  git tag -a phase488_matilda_stable -m "Phase 488 Matilda stable: SSE fix + request guards"
  echo "Tag created locally."
fi

echo
echo "=== PUSH TAG ==="
git push origin phase488_matilda_stable || echo "Tag may already exist on remote."

echo
echo "=== FINAL CHECK ==="
git tag --list | grep phase488_matilda_stable || true

echo
echo "=== DONE ==="
