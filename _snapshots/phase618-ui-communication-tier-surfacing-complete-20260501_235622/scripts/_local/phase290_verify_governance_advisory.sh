#!/bin/bash

# Phase 290 — Governance Advisory Verification Runner
# Deterministic verification of advisory contract + report builder
# Read-only validation only

set -e

echo "Running governance advisory contract tests..."

npm test src/governance/governance_advisory_contract.test.ts

echo "Governance advisory verification PASSED"

