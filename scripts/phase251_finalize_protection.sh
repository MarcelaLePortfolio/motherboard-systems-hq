#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse HEAD)"
HEAD_SHORT="$(git rev-parse --short HEAD)"
TAG="v251.1-governance-enforcement-architecture-protected-golden"

echo "== Phase 251 final protection =="
echo "root:   $ROOT"
echo "branch: $BRANCH"
echo "head:   $HEAD_SHORT"
echo

echo "== Ensure branch pushed =="
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

echo "== Create/update final protective tag on current HEAD =="
if git rev-parse "$TAG" >/dev/null 2>&1; then
  EXISTING_TAG_SHA="$(git rev-list -n 1 "$TAG")"
  if [[ "$EXISTING_TAG_SHA" != "$HEAD_SHA" ]]; then
    git tag -d "$TAG"
    if git ls-remote --tags origin | grep -q "refs/tags/$TAG$"; then
      git push --delete origin "$TAG"
    fi
    git tag -a "$TAG" -m "Phase 251 protected golden checkpoint"
  else
    echo "Tag already points to current HEAD."
  fi
else
  git tag -a "$TAG" -m "Phase 251 protected golden checkpoint"
fi
git push origin "$TAG"
echo

echo "== Wait for dashboard health =="
for i in {1..24}; do
  STATUS="$(docker compose ps --format json 2>/dev/null | python3 - << 'PY'
import sys, json
data = [json.loads(line) for line in sys.stdin if line.strip()]
status = ""
for item in data:
    if item.get("Service") == "dashboard":
        status = item.get("Health", "") or item.get("Status", "")
        break
print(status)
PY
)"
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
git log --oneline -5
git tag --list 'v251*' --sort=-creatordate
echo
echo "Phase 251 protected checkpoint complete."
