#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="d4e51e8ea"

test "$(git branch --show-current)" = "$BRANCH"

echo "SUCCESS_CRITERIA_LINEAGE_CORRIDOR=CLOSED"
echo "TERMINAL_STATE=HOLD"
echo "AUTHORITY_EXPANSION=NONE"
echo "NEXT_ACTION=AWAIT_NEW_SCOPED_OBJECTIVE"
