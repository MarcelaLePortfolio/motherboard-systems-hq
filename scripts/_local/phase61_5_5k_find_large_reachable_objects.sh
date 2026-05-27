#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

PACK="$(ls .git/objects/pack/*.idx | head -n 1)"
git verify-pack -v "$PACK" \
| sort -k3 -n \
| tail -n 25 \
| awk '{print $1, $3}' \
| while read -r sha size; do
  path="$(git rev-list --objects --all | awk -v s="$sha" '$1==s { $1=""; sub(/^ /,""); print; exit }')"
  printf '%12s  %s  %s\n' "$size" "$sha" "${path:-[no path found]}"
done
