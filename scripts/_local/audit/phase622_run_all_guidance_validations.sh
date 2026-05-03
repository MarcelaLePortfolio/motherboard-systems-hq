#!/bin/bash

echo "▶️ PHASE 622 — RUN ALL GUIDANCE VALIDATIONS"
echo ""

bash scripts/_local/audit/phase621_guidance_smoke_test.sh
echo ""

bash scripts/_local/audit/run_phase621_dev_probe.sh
echo ""

bash scripts/_local/audit/phase622_attach_validation.sh
echo ""

echo "✅ Guidance validation suite complete."
echo "Next: only wire attachExecutionGuidance to a real existing event-read path if all outputs are clean."
