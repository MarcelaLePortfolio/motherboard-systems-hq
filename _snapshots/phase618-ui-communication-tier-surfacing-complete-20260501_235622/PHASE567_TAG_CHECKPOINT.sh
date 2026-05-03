#!/usr/bin/env bash
set -e

echo "Tagging Phase 567 checkpoint..."
git tag -a phase567-checkpoint -m "Phase 567: Actionable operator surface (Retry enabled, inspector live)"
git push origin phase567-checkpoint

echo "Verifying tag..."
git tag | grep phase567-checkpoint

echo "DONE: Phase 567 checkpoint created and pushed"
