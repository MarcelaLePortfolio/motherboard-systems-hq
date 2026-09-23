#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="d1b036632"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "SUCCESS_CRITERIA_LINEAGE_CORRIDOR=CLOSED"
echo "TERMINAL_CHECKPOINT=d1b036632"
echo "AUTHORITY_EXPANSION=NONE"
echo "NEXT_ACTION=NEW_SCOPED_OBJECTIVE_REQUIRED"
