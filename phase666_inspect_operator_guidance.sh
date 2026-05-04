#!/usr/bin/env bash
set -euo pipefail

echo "=== operator-guidance route imports/functions ==="
grep -n "import \|function \|async function \|/api/guidance\|/events/operator-guidance\|guidance-history" server/routes/operator-guidance.mjs || true

echo
echo "=== first 180 lines ==="
nl -ba server/routes/operator-guidance.mjs | sed -n '1,180p'
