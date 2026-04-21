#!/usr/bin/env bash

set -e

echo "=== Tagging final Phase 487 release ==="
git tag -a phase487-final-stable-20260421 -m "Phase 487 FINAL: observability bridge + readable task surface complete"
git push origin phase487-final-stable-20260421

echo "=== Building final container ==="
docker build -f Dockerfile.dashboard -t motherboard-dashboard:phase487-final-stable-20260421 .

echo "=== Done ==="
