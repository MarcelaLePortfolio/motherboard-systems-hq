#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse HEAD)"
HEAD_SHORT="$(git rev-parse --short HEAD)"
FINAL_TAG="v251.4-governance-enforcement-architecture-final-head-sealed"

echo "== Phase 251 final HEAD seal =="
echo "root:   $ROOT"
echo "branch: $BRANCH"
echo "head:   $HEAD_SHORT"
echo

echo "== Push latest branch state =="
git push origin "$BRANCH"
echo

echo "== Create final tag on current HEAD =="
if git rev-parse "$FINAL_TAG" >/dev/null 2>&1; then
  git tag -d "$FINAL_TAG"
fi
if git ls-remote --tags origin | grep -q "refs/tags/$FINAL_TAG$"; then
  git push origin ":refs/tags/$FINAL_TAG"
fi
git tag -a "$FINAL_TAG" -m "Phase 251 final HEAD sealed checkpoint"
git push origin "$FINAL_TAG"
echo

echo "== Container health verification =="
for i in {1..24}; do
  STATUS_LINE="$(docker compose ps dashboard 2>/dev/null | tail -n 1 || true)"
  echo "${STATUS_LINE:-dashboard status unavailable}"
  if echo "$STATUS_LINE" | grep -qi "healthy"; then
    break
  fi
  sleep 5
done
echo

echo "== Final compose state =="
docker compose ps
echo

echo "== Final git verification =="
git status --short
git log --oneline -6
git tag --list 'v251*' --sort=-creatordate
echo
echo "Phase 251 final HEAD seal complete."
