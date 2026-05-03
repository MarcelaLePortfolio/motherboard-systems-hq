#!/bin/bash

# Phase 291 — Governance Advisory Normalization Verification Runner
# Deterministic verification only

set -e

echo "Running governance normalization tests..."

npm test src/governance/governance_advisory_normalizer.test.ts

echo "Governance normalization verification PASSED"

