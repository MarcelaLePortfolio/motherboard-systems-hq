#!/usr/bin/env bash
set -e

echo "Tagging Phase 569 checkpoint..."
git tag -a phase569-checkpoint -m "Phase 569: Coherent operator surface (Requeue semantics corrected)"
git push origin phase569-checkpoint

echo "Verifying tag..."
git tag | grep phase569-checkpoint

echo "DONE: Phase 569 checkpoint created and pushed"
