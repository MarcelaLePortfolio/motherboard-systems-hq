#!/usr/bin/env bash

set -e

echo "=== Executing Phase 487 Finalization ==="

echo "--- Tagging ---"
git tag -a phase487-final-stable-20260421 -m "Phase 487 FINAL: observability bridge + readable task surface complete"
git push origin phase487-final-stable-20260421

echo "--- Building Container ---"
docker build -f Dockerfile.dashboard -t motherboard-dashboard:phase487-final-stable-20260421 .

echo "--- Verification ---"
docker images | grep motherboard-dashboard | grep phase487-final-stable-20260421 || echo "Image not found"

echo "=== Phase 487 FINAL COMPLETE ==="
