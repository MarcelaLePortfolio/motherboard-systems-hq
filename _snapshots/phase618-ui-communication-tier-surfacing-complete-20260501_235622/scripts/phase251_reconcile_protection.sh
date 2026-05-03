#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
HEAD_SHA="$(git rev-parse HEAD)"
HEAD_SHORT="$(git rev-parse --short HEAD)"
FINAL_TAG="v251.1-governance-enforcement-architecture-protected-golden"

echo "== Phase 251 protection reconciliation =="
echo "root:   $ROOT"
echo "branch: $BRANCH"
echo "head:   $HEAD_SHORT"
echo

echo "== Ensure working tree clean enough to seal =="
git status --short
echo

echo "== Push latest branch state if needed =="
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

echo "== Repoint final tag to current HEAD if needed =="
if git rev-parse "$FINAL_TAG" >/dev/null 2>&1; then
  TAG_SHA="$(git rev-list -n 1 "$FINAL_TAG")"
  echo "current tag sha: $TAG_SHA"
  if [[ "$TAG_SHA" != "$HEAD_SHA" ]]; then
    git tag -d "$FINAL_TAG"
    if git ls-remote --tags origin | grep -q "refs/tags/$FINAL_TAG$"; then
      git push --delete origin "$FINAL_TAG"
    fi
    git tag -a "$FINAL_TAG" -m "Phase 251 protected golden checkpoint"
    git push origin "$FINAL_TAG"
    echo "Retagged $FINAL_TAG to HEAD."
  else
    echo "Tag already points to current HEAD."
  fi
else
  git tag -a "$FINAL_TAG" -m "Phase 251 protected golden checkpoint"
  git push origin "$FINAL_TAG"
  echo "Created and pushed $FINAL_TAG."
fi
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
git log --oneline -5
git tag --list 'v251*' --sort=-creatordate
echo
echo "Phase 251 reconciliation complete."
