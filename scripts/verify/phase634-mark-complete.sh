#!/bin/bash
set -e

echo "Marking Phase 634 as complete..."

git tag -a phase634-complete -m "Phase 634 complete: Atlas subsystem surfaced (read-only) and validated"

git push origin phase634-complete

echo "Phase 634 tagged and complete."
