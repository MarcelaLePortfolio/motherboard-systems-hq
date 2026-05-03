#!/bin/bash

echo "▶️ PHASE 621 — RUN + CAPTURE OUTPUT"

OUTPUT_FILE="phase621_guidance_output.log"

echo "Running guidance test and capturing output to $OUTPUT_FILE ..."
GUIDANCE_TEST=true node server/execution_guidance_runner.mjs | tee $OUTPUT_FILE

echo ""
echo "📊 Verification Checklist:"
echo "1. Look for [execution-guidance] logs"
echo "2. Confirm classifications appear (success / retryable / blocked)"
echo "3. Confirm NO errors"

echo ""
echo "📁 Output saved to: $OUTPUT_FILE"
