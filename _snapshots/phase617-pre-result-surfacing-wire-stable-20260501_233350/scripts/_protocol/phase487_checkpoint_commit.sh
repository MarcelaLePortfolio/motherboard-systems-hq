#!/bin/bash
set -e

echo "=== PHASE 487 CHECKPOINT: PRE-STABILIZATION SNAPSHOT ==="

# Create checkpoint commit
git add .
git commit -m "Phase 487 checkpoint — post-tsconfig fix, system structurally verified, type surface expanded (pre-stabilization)"

# Create annotated tag
git tag -a v487.0-pre-stabilization-checkpoint -m "Checkpoint: system intact, expanded TypeScript surface exposing legacy debt, safe rollback anchor"

# Push branch and tag
git push origin phase119-dashboard-cognition-contract
git push origin v487.0-pre-stabilization-checkpoint

echo "=== OPTIONAL: CONTAINER SNAPSHOT ==="

# Build container snapshot (non-destructive)
docker build -t motherboard-systems-hq:v487-checkpoint .

echo "=== DONE ==="
