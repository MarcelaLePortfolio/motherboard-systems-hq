#!/usr/bin/env bash
set -euo pipefail

echo "=== Phase 702 Tag + Containerize + Snapshot ==="

echo
echo "Tagging Phase 702..."
git tag -a phase702-sealed -m "Phase 702 sealed snapshot (UI trust + validation complete)"
git push origin phase702-sealed

echo
echo "Building container snapshot..."
if command -v docker >/dev/null 2>&1; then
  docker build -t motherboard-systems-hq:phase702 .
  docker tag motherboard-systems-hq:phase702 motherboard-systems-hq:latest || true
  echo "Container build complete."
else
  echo "Docker not available — skipping containerization."
fi

echo
echo "Recording snapshot artifact..."
SNAPSHOT="docs/phase702-container-snapshot.md"

{
  echo "# Phase 702 Container Snapshot"
  echo
  echo "Generated: $(date)"
  echo
  echo "## Git Tag"
  echo "phase702-sealed"
  echo
  echo "## Commit"
  git rev-parse HEAD
  echo
  echo "## Notes"
  echo "- UI trust aligned"
  echo "- Replay validation passing"
  echo "- Safe sealed state"
} > "$SNAPSHOT"

git add "$SNAPSHOT"
git commit -m "Phase 702: container snapshot record"
git push

echo
echo "Final status:"
git status --short
