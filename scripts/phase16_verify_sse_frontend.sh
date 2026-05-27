#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== Phase 16: verify frontend SSE wiring + detect stale bundle strings ==="

echo
echo "1) Confirm source has named-event listeners"
rg -n "addEventListener\\(|ops\\.state|reflections\\.state|eventNames\\s*=\\s*\\[" public/js/dashboard-status.js

echo
echo "2) Detect legacy strings (should be gone after rebuild)"
LEGACY_PATTERNS=(
  "Failed to open OPS SSE connection"
  "OPS SSE error"
  "Failed to open Reflections SSE connection"
  "Reflections SSE error"
)

for p in "${LEGACY_PATTERNS[@]}"; do
  echo
  echo "--- Searching: $p ---"
  rg -n --fixed-strings "$p" public/js public || true
done

echo
echo "3) Show bundle entrypoint references"
rg -n "dashboard-status\\.js|dashboard-status\\.mjs|dashboard-status" \
  public/js/dashboard-bundle-entry.js public/bundle.js public/dashboard.html public/index.html || true

echo
echo "4) If legacy strings exist in bundle.js, rebuild dashboard bundle"
if rg -q --fixed-strings "Failed to open OPS SSE connection" public/bundle.js; then
  echo "Legacy strings detected in public/bundle.js; rebuilding dashboard bundle..."
  if [ -x ./scripts/build_dashboard_bundle.sh ]; then
    ./scripts/build_dashboard_bundle.sh
  elif [ -f package.json ] && rg -q '"build:dashboard-bundle"' package.json; then
    npm run build:dashboard-bundle
  else
    echo "No known build path found. Search build entrypoints:"
    rg -n "build:dashboard-bundle|esbuild public/js/dashboard-bundle-entry\\.js|build_dashboard_bundle" package.json scripts || true
    exit 1
  fi
  echo "Rebuild complete."
fi

echo
echo "5) Final checks"
node -e 'const fs=require("fs"); const b=fs.readFileSync("public/bundle.js","utf8"); console.log("bundle has addEventListener:", b.includes("addEventListener(")); console.log("bundle has ops.state:", b.includes("ops.state")); console.log("bundle has reflections.state:", b.includes("reflections.state"));'
echo
echo "- git status:"
git status --porcelain
