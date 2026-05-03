#!/bin/bash

# Phase 305 — Governance Replay Runner
# Deterministic replay validation across fixture corpus

set -e

echo "Phase 305 governance replay verification..."

npm test src/governance/governance_fixture_corpus.test.ts
npm test src/governance/governance_advisory_pipeline.test.ts

echo "Phase 305 governance replay PASSED"

