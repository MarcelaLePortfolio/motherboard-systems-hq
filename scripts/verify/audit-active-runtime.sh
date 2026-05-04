#!/bin/bash
set -e

echo "PHASE 637 — ACTIVE RUNTIME AUDIT"

echo ""
echo "1. Checking for bootstrap route registration in active server..."
grep -R "applyRouteRegistration" server.js server 2>/dev/null || echo "⚠️ bootstrap helper not found in active server"

echo ""
echo "2. Checking for subsystem status route reference..."
grep -R "/api/subsystem-status" server.js server 2>/dev/null || echo "⚠️ subsystem status route not referenced"

echo ""
echo "3. Checking for subsystem SSE route reference..."
grep -R "/events/subsystem-status" server.js server 2>/dev/null || echo "⚠️ subsystem SSE route not referenced"

echo ""
echo "4. Checking route registration imports..."
grep -R "subsystem-status\\|subsystem-sse" server 2>/dev/null || echo "⚠️ subsystem route files not imported"

echo ""
echo "AUDIT COMPLETE — review warnings above"
