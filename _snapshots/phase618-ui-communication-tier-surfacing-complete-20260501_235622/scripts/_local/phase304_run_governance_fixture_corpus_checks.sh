#!/bin/bash

# Phase 304 — Governance fixture corpus verification
# Deterministic regression corpus validation

set -e

echo "Phase 304 governance fixture corpus verification..."

npm test src/governance/governance_fixture_corpus.test.ts

echo "Phase 304 verification PASSED"

