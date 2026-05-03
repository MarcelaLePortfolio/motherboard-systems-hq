#!/bin/bash

echo "🔍 PHASE 621 — EXECUTION GUIDANCE SMOKE TEST"

echo "Running guidance runner in test mode..."
GUIDANCE_TEST=true node server/execution_guidance_runner.mjs

echo ""
echo "✅ If you see [execution-guidance] logs with classifications (success / retryable), the layer is working."
echo "❌ If no output appears or errors occur, stop and investigate before proceeding."
