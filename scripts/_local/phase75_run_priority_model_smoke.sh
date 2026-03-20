#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 75 — PRIORITY MODEL SMOKE"

tsx scripts/_local/phase75_operator_helper_priority_smoke.ts

echo "PHASE 75 SMOKE COMPLETE"
