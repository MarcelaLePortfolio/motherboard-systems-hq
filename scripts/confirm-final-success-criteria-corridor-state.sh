#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="9e820743a"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "SUCCESS_CRITERIA_LINEAGE_CORRIDOR=CLOSED"
echo "FINAL_CORRIDOR_COMMIT=9e820743a2de1f68de42e5e01cc1be17a569151c"
echo "AUTHORITY_EXPANSION=NONE"
echo "NEXT_ACTION=NEW_SCOPED_OBJECTIVE_REQUIRED"
