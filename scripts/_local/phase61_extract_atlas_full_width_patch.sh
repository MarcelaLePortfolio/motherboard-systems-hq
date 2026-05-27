#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE_COMMIT="${1:-2b467a03}"
OUT_PATCH="${2:-/tmp/phase61_atlas_full_width.patch}"

git rev-parse -q --verify "${SOURCE_COMMIT}^{commit}" >/dev/null

git --no-pager diff "${SOURCE_COMMIT}^" "${SOURCE_COMMIT}" -- public/dashboard.html public/js/phase61_tabs_workspace.js > "$OUT_PATCH"

echo "PATCH_SOURCE=${SOURCE_COMMIT}"
echo "PATCH_PATH=${OUT_PATCH}"
echo
sed -n '/atlas-status-card/,+60p' "$OUT_PATCH" || true
echo
sed -n '/Atlas Subsystem Status/,+80p' "$OUT_PATCH" || true
