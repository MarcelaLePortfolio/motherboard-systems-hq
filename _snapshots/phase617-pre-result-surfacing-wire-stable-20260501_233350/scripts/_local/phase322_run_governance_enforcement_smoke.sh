#!/bin/bash

# Phase 322 — Governance Enforcement Smoke Runner
# Deterministic enforcement verification
# No runtime wiring
# No execution mutation

set -e

echo "Phase 322 governance enforcement smoke starting..."

npx tsx scripts/_local/phase322_run_governance_enforcement_smoke.ts

echo "Phase 322 governance enforcement smoke PASSED"
