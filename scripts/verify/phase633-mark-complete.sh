#!/bin/bash
set -e

echo "Marking Phase 633 as complete..."

git tag -a phase633-complete -m "Phase 633 complete: schema persistence + subsystem observability verified"

git push origin phase633-complete

echo "Phase 633 tagged and complete."
