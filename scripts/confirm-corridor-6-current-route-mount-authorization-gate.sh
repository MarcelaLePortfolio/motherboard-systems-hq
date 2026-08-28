#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="e14522346"

echo "=== CORRIDOR 6 CURRENT ROUTE MOUNT AUTHORIZATION GATE ==="
test "$(git rev-parse --short HEAD)" = "${EXPECTED_HEAD}"

echo "LATEST_VERIFIED_COMMIT=e14522346b20a6e266ebdc7f80e562705d946c9b"
echo "DEDICATED_ROUTE_MOUNTED=NO"
echo "PRODUCTION_REACHABILITY=NO"
echo "USER_INTENT_AUTHORITY_REQUIRED=YES"
echo "EXPLICIT_USER_CHAT_AUTHORIZATION_PRESENT=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "REQUIRED_USER_CHAT_PHRASE=I authorize the bounded Corridor 6 Dedicated Route Mount and Production Reachability implementation plus targeted tests."
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
