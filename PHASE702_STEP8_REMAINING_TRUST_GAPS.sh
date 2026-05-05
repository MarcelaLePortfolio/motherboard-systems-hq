#!/usr/bin/env bash
set -euo pipefail

echo "=== Remaining Phase 702 Trust Gaps ==="
echo
cat docs/phase702-ui-trust-summary.md
echo
echo "=== Current working tree ==="
git status --short
