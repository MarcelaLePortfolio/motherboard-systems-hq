#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse HEAD)"
HEAD_SHORT="$(git rev-parse --short HEAD)"
FINAL_TAG="v251.1-governance-enforcement-architecture-protected-golden"
BACKFILL_TAG="v251.2-governance-enforcement-architecture-fully-sealed"

echo "== Phase 251 complete protection repair =="
echo "root:   $ROOT"
echo "branch: $BRANCH"
echo "head:   $HEAD_SHORT"
echo

echo "== Push latest branch state =="
git fetch origin "$BRANCH" --tags
LOCAL_SHA="$(git rev-parse "$BRANCH")"
REMOTE_SHA="$(git rev-parse "origin/$BRANCH")"
echo "local:  $LOCAL_SHA"
echo "remote: $REMOTE_SHA"
if [[ "$LOCAL_SHA" != "$REMOTE_SHA" ]]; then
  git push origin "$BRANCH"
else
  echo "Branch already synced."
fi
echo

echo "== Delete stale remote/local final tag if present =="
if git ls-remote --tags origin | grep -q "refs/tags/$FINAL_TAG$"; then
  git push origin ":refs/tags/$FINAL_TAG"
fi
if git rev-parse "$FINAL_TAG" >/dev/null 2>&1; then
  git tag -d "$FINAL_TAG"
fi
echo

echo "== Recreate final tag on current HEAD =="
git tag -a "$FINAL_TAG" -m "Phase 251 protected golden checkpoint"
git push origin "$FINAL_TAG"
echo

echo "== Add backfill seal tag on current HEAD =="
if git rev-parse "$BACKFILL_TAG" >/dev/null 2>&1; then
  git tag -d "$BACKFILL_TAG"
fi
if git ls-remote --tags origin | grep -q "refs/tags/$BACKFILL_TAG$"; then
  git push origin ":refs/tags/$BACKFILL_TAG"
fi
git tag -a "$BACKFILL_TAG" -m "Phase 251 fully sealed checkpoint"
git push origin "$BACKFILL_TAG"
echo

echo "== Wait for dashboard health =="
for i in {1..24}; do
  STATUS="$(docker compose ps --format json 2>/dev/null | python3 -c '
import sys, json
items = [json.loads(line) for line in sys.stdin if line.strip()]
status = ""
for item in items:
    if item.get("Service") == "dashboard":
        status = item.get("Health", "") or item.get("Status", "")
        break
print(status)
')"
  echo "dashboard health/status: ${STATUS:-unknown}"
  if [[ "$STATUS" == "healthy" ]] || [[ "$STATUS" == *"(healthy)"* ]]; then
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
echo "Phase 251 protection fully repaired."
