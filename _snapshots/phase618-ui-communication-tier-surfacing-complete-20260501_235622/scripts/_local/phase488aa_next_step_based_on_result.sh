#!/bin/bash
set -euo pipefail

echo "When you reply with the result, next action will be:"
echo
echo "REPLY WORKED  -> we remove debug + guards cleanly (success path)"
echo "TIMEOUT HIT   -> we isolate network/socket exhaustion root cause"
echo "NO UI CHANGE  -> we inspect event wiring / DOM binding failure"
echo
echo "Reply now with exactly one of:"
echo "REPLY WORKED"
echo "TIMEOUT HIT"
echo "NO UI CHANGE"
