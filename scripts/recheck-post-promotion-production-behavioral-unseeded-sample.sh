#!/usr/bin/env bash
set -euo pipefail

echo "=== RECHECK POST-PROMOTION PRODUCTION BEHAVIORAL UNSEEDED SAMPLE ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
git merge-base --is-ancestor e9b94caa HEAD

checker="scripts/check-post-promotion-production-behavioral-unseeded-sample.sh"
test -x "$checker"

"$checker"
