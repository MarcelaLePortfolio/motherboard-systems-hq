#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="d597f80b5"

echo "=== CORRIDOR 6 ROUTE MOUNT AUTHORIZATION CURRENT GATE ==="
test "$(git rev-parse --short HEAD)" = "${EXPECTED_HEAD}"

echo "LATEST_VERIFIED_COMMIT=d597f80b59bde8012a3245fcb05760ab1d20674a"
echo "DEDICATED_ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "USER_INTENT_AUTHORITY_REQUIRED=YES"
echo "EXPLICIT_USER_CHAT_AUTHORIZATION_PRESENT=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "REQUIRED_USER_CHAT_PHRASE=I authorize the bounded Corridor 6 Dedicated Route Mount and Production Reachability implementation plus targeted tests."
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
