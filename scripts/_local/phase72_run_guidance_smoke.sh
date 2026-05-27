#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 72 — OPERATOR GUIDANCE SMOKE"

tsx scripts/_local/phase72_operator_guidance_smoke.ts

echo "PHASE 72 SMOKE COMPLETE"
