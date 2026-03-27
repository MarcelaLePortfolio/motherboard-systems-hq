#!/bin/bash

# Phase 295 — Governance summary verification
# Deterministic cognition validation only

set -e

echo "Phase 295 governance summary verification..."

npm test src/governance/governance_advisory_summary_builder.test.ts

echo "Phase 295 verification PASSED"

