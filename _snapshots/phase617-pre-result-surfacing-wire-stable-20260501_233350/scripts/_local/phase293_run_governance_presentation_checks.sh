#!/bin/bash

# Phase 293 — Governance presentation deterministic check
# Read-only cognition verification

set -e

echo "Phase 293 verification starting..."

npm test src/governance/governance_advisory_presenter.test.ts

echo "Phase 293 verification PASSED"

