#!/bin/bash

# Phase 292 — Governance Advisory Presentation Verification Runner
# Deterministic verification only

set -e

echo "Running governance presentation tests..."

npm test src/governance/governance_advisory_presenter.test.ts

echo "Governance presentation verification PASSED"

