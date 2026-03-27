#!/bin/bash

# Phase 299 — Governance operator view verification
# Deterministic cognition validation

set -e

echo "Phase 299 governance operator view verification..."

npm test src/governance/governance_advisory_operator_view.test.ts

echo "Phase 299 verification PASSED"

