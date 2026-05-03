#!/bin/bash

# Phase 302 — Full Governance Advisory Suite Runner
# One-command deterministic governance cognition verification

set -e

echo "Running full governance advisory suite..."

npm test src/governance/governance_signal_classifier.test.ts
npm test src/governance/governance_advisory_normalizer.test.ts
npm test src/governance/governance_advisory_presenter.test.ts
npm test src/governance/governance_advisory_summary_builder.test.ts
npm test src/governance/governance_advisory_digest.test.ts
npm test src/governance/governance_advisory_operator_view.test.ts
npm test src/governance/governance_advisory_pipeline.test.ts

echo "Full governance advisory suite PASSED"

