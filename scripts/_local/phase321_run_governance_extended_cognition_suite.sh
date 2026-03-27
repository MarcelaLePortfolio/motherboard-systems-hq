#!/bin/bash

# Phase 321 — Governance Extended Cognition Suite
# Deterministic cognition-only verification runner
# No runtime mutation
# No execution influence

set -e

echo "Phase 321 governance extended cognition suite starting..."

npm test src/governance/governance_cognition_determinism_sentinel.test.ts
npm test src/governance/governance_replay_verifier.test.ts
npm test src/governance/governance_explanation_layer.test.ts
npm test src/governance/governance_contradiction_detector.test.ts
npm test src/governance/governance_confidence_score.test.ts
npm test src/governance/governance_audit_trace_emitter.test.ts
npm test src/governance/governance_signal_registry.test.ts
npm test src/governance/governance_advisory_consistency_guard.test.ts
npm test src/governance/governance_stability_index.test.ts

echo "Phase 321 governance extended cognition suite PASSED"

