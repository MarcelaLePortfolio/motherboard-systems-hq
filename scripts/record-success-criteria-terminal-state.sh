#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="126317ba4"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "SUCCESS_CRITERIA_LINEAGE_CORRIDOR=CLOSED"
echo "TERMINAL_STATE_COMMIT=126317ba4c88f38c972f5b949e39db41ad76070f"
echo "AUTHORITY_EXPANSION=NONE"
echo "FURTHER_WORK_REQUIRES_NEW_SCOPED_OBJECTIVE=YES"
