#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="d112bf30db223018014b91e3f64174d0725abc82"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "=== PORT 5173 ==="
lsof -nP -iTCP:5173 -sTCP:LISTEN || true

echo
echo "=== ROOT PACKAGE SCRIPTS ==="
node -e 'const p=require("./package.json"); console.log(JSON.stringify(p.scripts,null,2))'

echo
echo "=== FRONTEND / VITE CANDIDATES ==="
find . \
  -path './node_modules' -prune -o \
  -path './dist' -prune -o \
  \( -name 'vite.config.*' -o -name 'package.json' -o -name 'index.html' \) \
  -print | sort

echo
echo "=== VITE PACKAGE SCRIPTS ==="
while IFS= read -r pkg; do
  dir="$(dirname "$pkg")"
  if grep -q '"vite"' "$pkg" 2>/dev/null || \
     find "$dir" -maxdepth 1 -name 'vite.config.*' -print -quit | grep -q .; then
    echo "--- ${pkg} ---"
    node -e '
      const fs=require("fs");
      const p=JSON.parse(fs.readFileSync(process.argv[1],"utf8"));
      console.log(JSON.stringify(p.scripts || {},null,2));
    ' "$pkg"
  fi
done < <(
  find . \
    -path './node_modules' -prune -o \
    -path './dist' -prune -o \
    -name package.json -print
)

echo
echo "=== DASHBOARD REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E '5173|vite|dashboard' \
  package.json . 2>/dev/null | head -n 160 || true

echo
echo "DASHBOARD_5173_LISTENER=$(
  if lsof -nP -iTCP:5173 -sTCP:LISTEN >/dev/null 2>&1; then
    echo YES
  else
    echo NO
  fi
)"
echo "PRODUCTION_ROUTE_ACTIVATION_ATTEMPTED=NO"
echo "NEXT_ACTION=IDENTIFY_AND_RESTORE_DASHBOARD_RUNTIME"
