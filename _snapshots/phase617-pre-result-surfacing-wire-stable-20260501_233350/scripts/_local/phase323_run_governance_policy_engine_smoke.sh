#!/bin/bash

# Phase 323 — Governance Policy Engine Smoke Runner
# Deterministic policy verification
# No runtime wiring
# No execution mutation

set -e

echo "Phase 323 governance policy engine smoke starting..."

npx tsx scripts/_local/phase323_run_governance_policy_engine_smoke.ts

echo "Phase 323 governance policy engine smoke PASSED"
