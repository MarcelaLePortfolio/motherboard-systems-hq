#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 77 — ADAPTATION GUARDRAILS SMOKE"

tsx scripts/_local/phase77_adaptation_guardrails_smoke.ts

echo "PHASE 77 ADAPTATION GUARDRAILS SMOKE COMPLETE"
