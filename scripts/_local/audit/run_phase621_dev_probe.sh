#!/bin/bash

echo "▶️ PHASE 621 — DEV PROBE (END-TO-END)"

echo "Running execution guidance dev probe..."
node server/integrations/execution_guidance_dev_probe.mjs

echo ""
echo "📊 Verification Checklist:"
echo "1. Confirm 3 logs appear"
echo "2. Expect classifications:"
echo "   - success"
echo "   - retryable"
echo "   - blocked"
echo "3. Confirm NO errors"
