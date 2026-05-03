#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 75 — RANKED HELPERS SMOKE"

tsx scripts/_local/phase75_ranked_helpers_smoke.ts

echo "PHASE 75 RANKED HELPERS SMOKE COMPLETE"
