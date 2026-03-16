#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 77 — SIGNAL SEVERITY SMOKE"

tsx scripts/_local/phase77_signal_severity_model_smoke.ts

echo "PHASE 77 SIGNAL SEVERITY SMOKE COMPLETE"
