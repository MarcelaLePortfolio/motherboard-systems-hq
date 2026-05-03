#!/bin/bash

echo "▶️ PHASE 621 — LIVE EVENT VALIDATION (READ-ONLY)"

echo "Simulating live stream ingestion via dev probe..."
node server/integrations/execution_guidance_dev_probe.mjs | tee phase621_live_validation.log

echo ""
echo "📊 VALIDATION REQUIREMENTS:"
echo "✔ Logs must include [execution-guidance]"
echo "✔ Each event must output a classification"
echo "✔ No crashes or stack traces"
echo "✔ No task mutations or side effects"

echo ""
echo "📁 Output saved to: phase621_live_validation.log"
echo "➡️ If all checks pass, Phase 621 PASSIVE GUIDANCE is VERIFIED."
