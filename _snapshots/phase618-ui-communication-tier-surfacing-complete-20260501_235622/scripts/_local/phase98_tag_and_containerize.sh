#!/usr/bin/env bash
set -euo pipefail

PHASE98_COMMIT="48184769"
PHASE98_TAG="v98.0-governance-awareness-golden"

echo
echo "PHASE 98 STATUS REVIEW"
echo "====================="
echo "1) The original launch-matilda.mjs issue was the invalid shell-style '#' comment inside an .mjs file."
echo "   That syntax error is now fixed."
echo
echo "2) The global TypeScript check is still failing, but for broader pre-existing repo issues outside Phase 98."
echo "   Examples already surfaced:"
echo "   - unresolved module paths"
echo "   - express typing/import mismatches"
echo "   - rootDir / ts extension config issues"
echo "   - older script-layer drift"
echo "   This means the Phase 98 blocker was real, but it was not the only blocker."
echo

echo "Current HEAD:"
git rev-parse --short HEAD
echo

echo "Tagging Phase 98 commit specifically:"
if git rev-parse "$PHASE98_TAG" >/dev/null 2>&1; then
  echo "  Tag already exists locally: $PHASE98_TAG"
else
  git tag -a "$PHASE98_TAG" "$PHASE98_COMMIT" -m "Phase 98 governance awareness golden"
  echo "  Created annotated tag $PHASE98_TAG at $PHASE98_COMMIT"
fi

git push origin "$PHASE98_TAG"

echo
echo "Tag verification:"
git show --no-patch --decorate "$PHASE98_TAG"
echo

echo "Containerization check:"
compose_file=""
for candidate in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [ -f "$candidate" ]; then
    compose_file="$candidate"
    break
  fi
done

if [ -n "$compose_file" ]; then
  echo "  Compose file found: $compose_file"
  echo "  Services:"
  docker compose -f "$compose_file" config --services
  echo
  echo "  Rebuilding and starting containers anyway..."
  docker compose -f "$compose_file" up -d --build
  echo
  echo "  Container status:"
  docker compose -f "$compose_file" ps
else
  echo "  No root compose file found."
  echo "  Containerization can still be done, but not from a default root compose file."
fi

echo
echo "Recent refs:"
git log --oneline --decorate -5
