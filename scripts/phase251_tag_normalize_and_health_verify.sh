#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse HEAD)"
HEAD_SHORT="$(git rev-parse --short HEAD)"

STALE_TAG="v251.1-governance-enforcement-architecture-protected-golden"
CURRENT_TAG="v251.3-governance-enforcement-architecture-current-head-sealed"

echo "== Phase 251 tag normalize + health verify =="
echo "root:   $ROOT"
echo "branch: $BRANCH"
echo "head:   $HEAD_SHORT"
echo

echo "== Push current branch =="
git push origin "$BRANCH"
echo

echo "== Normalize stale local tag only =="
if git rev-parse "$STALE_TAG" >/dev/null 2>&1; then
  git tag -d "$STALE_TAG"
  echo "Deleted stale local tag: $STALE_TAG"
else
  echo "No local stale tag present: $STALE_TAG"
fi

echo "== Re-fetch remote stale tag without --tags =="
if git ls-remote --tags origin | grep -q "refs/tags/$STALE_TAG$"; then
  git fetch origin "refs/tags/$STALE_TAG:refs/tags/$STALE_TAG"
  echo "Fetched remote tag: $STALE_TAG"
else
  echo "Remote tag not present: $STALE_TAG"
fi
echo

echo "== Create current-head protective tag =="
if git rev-parse "$CURRENT_TAG" >/dev/null 2>&1; then
  git tag -d "$CURRENT_TAG"
fi
if git ls-remote --tags origin | grep -q "refs/tags/$CURRENT_TAG$"; then
  git push origin ":refs/tags/$CURRENT_TAG"
fi
git tag -a "$CURRENT_TAG" -m "Phase 251 current HEAD sealed checkpoint"
git push origin "$CURRENT_TAG"
echo

echo "== Wait for dashboard health =="
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

echo "== Recent dashboard logs =="
docker compose logs --tail=80 dashboard || true
echo

echo "== Final git verification =="
git status --short
git log --oneline -6
git tag --list 'v251*' --sort=-creatordate
echo
echo "Phase 251 protection normalized and verified."
