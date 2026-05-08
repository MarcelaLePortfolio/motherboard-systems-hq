
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 715 GIT PUSH RECOVERY ====="

echo ""

echo "[1] Current branch / remote state"

git branch --show-current

git status --short

git log --oneline --decorate -8

echo ""

echo "[2] Fetch origin/dev and confirm commits ahead"

git fetch origin dev --tags

git log --oneline --decorate origin/dev..HEAD || true

echo ""

echo "[3] Inspect largest blob objects only in commits ahead of origin/dev"

TMP_OBJECTS="$(mktemp)"

TMP_BLOBS="$(mktemp)"

trap 'rm -f "$TMP_OBJECTS" "$TMP_BLOBS"' EXIT

git rev-list --objects origin/dev..HEAD > "$TMP_OBJECTS" || true

while IFS= read -r line; do

  oid="${line%% *}"

  path="${line#* }"

  if [ "$oid" = "$path" ]; then

    path=""

  fi

  type="$(git cat-file -t "$oid" 2>/dev/null || true)"

  if [ "$type" = "blob" ]; then

    size="$(git cat-file -s "$oid")"

    printf "%s %s %s\n" "$size" "$oid" "$path" >> "$TMP_BLOBS"

  fi

done < "$TMP_OBJECTS"

if [ -s "$TMP_BLOBS" ]; then

  sort -nr "$TMP_BLOBS" | head -40 | awk '{size=$1; oid=$2; $1=""; $2=""; printf "%.2f MB %s\n", size/1024/1024, $0}'

else

  echo "No unpushed blob objects found."

fi

echo ""

echo "[4] Push branch only"

git push origin dev

echo ""

echo "[5] Push only the intended Phase 715 tag if it exists locally"

if git rev-parse "phase715-pre-execution-evidence-ui" >/dev/null 2>&1; then

  git push origin "phase715-pre-execution-evidence-ui"

else

  echo "No local phase715-pre-execution-evidence-ui tag found."

fi

echo ""

echo "[6] Verify remote branch and tag"

git ls-remote --heads origin dev

git ls-remote --tags origin | grep "phase715-pre-execution-evidence-ui" || true

echo ""

echo "[7] Final status"

git status --short

echo "===== PHASE 715 GIT PUSH RECOVERY COMPLETE ====="

