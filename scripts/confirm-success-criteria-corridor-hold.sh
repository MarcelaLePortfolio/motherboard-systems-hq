#!/usr/bin/env bash
set -euo pipefail
cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="17d3396ed"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "SUCCESS_CRITERIA_LINEAGE_CORRIDOR=CLOSED"
echo "TERMINAL_STATE=HOLD"
echo "AUTHORITY_EXPANSION=NONE"
echo "NEXT_ACTION=AWAIT_NEW_SCOPED_OBJECTIVE"
