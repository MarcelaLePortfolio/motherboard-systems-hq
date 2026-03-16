#!/usr/bin/env bash

set -euo pipefail

echo "PHASE 74 — OPERATOR WORKFLOW HELPERS SMOKE"

tsx scripts/_local/phase74_operator_workflow_helpers_smoke.ts

echo "PHASE 74 SMOKE COMPLETE"
