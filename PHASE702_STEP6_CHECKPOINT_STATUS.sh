#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 702 Checkpoint Status ==="
git status --short

echo
echo "Recent commits:"
git log --oneline -n 8

echo
echo "Validation artifact:"
sed -n '1,120p' docs/phase702-validation-success.md
