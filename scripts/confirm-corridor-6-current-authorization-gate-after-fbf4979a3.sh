#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="fbf4979a3"

echo "=== CORRIDOR 6 CURRENT AUTHORIZATION GATE ==="
test "$(git rev-parse --short HEAD)" = "${EXPECTED_HEAD}"

echo "LATEST_VERIFIED_COMMIT=fbf4979a3fb958136df85af58a041c463f2429cd"
echo "DEDICATED_ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "USER_INTENT_AUTHORITY_REQUIRED=YES"
echo "EXPLICIT_USER_CHAT_AUTHORIZATION_PRESENT=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "REQUIRED_USER_CHAT_PHRASE=I authorize the bounded Corridor 6 Dedicated Route Mount and Production Reachability implementation plus targeted tests."
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
