#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 73 — OPERATOR SAFETY GATES SMOKE"

tsx scripts/_local/phase73_operator_safety_gates_smoke.ts

echo "PHASE 73 SMOKE COMPLETE"
