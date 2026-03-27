#!/bin/bash

# Phase 297 — Governance digest verification
# Deterministic cognition validation

set -e

echo "Phase 297 governance digest verification..."

npm test src/governance/governance_advisory_digest.test.ts

echo "Phase 297 verification PASSED"

