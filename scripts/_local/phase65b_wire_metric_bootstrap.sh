#!/usr/bin/env bash
set -euo pipefail

TARGET="public/js/dashboard-bundle-entry.js"
MARKER='/* PHASE65B_TELEMETRY_BOOTSTRAP */'
SCRIPT_LINE='document.body.appendChild(Object.assign(document.createElement("script"),{src:"/js/telemetry/phase65b_metric_bootstrap.js",defer:true}));'

if grep -Fq "$MARKER" "$TARGET"; then
  echo "Phase 65B bootstrap already wired"
  exit 0
fi

TMP_FILE="$(mktemp)"

{
  cat "$TARGET"
  printf '\n%s\n' "$MARKER"
  printf '(function(){\n'
  printf '  if (typeof document === "undefined") return;\n'
  printf '  if (document.querySelector(\'script[src="/js/telemetry/phase65b_metric_bootstrap.js"]\')) return;\n'
  printf '  %s\n' "$SCRIPT_LINE"
  printf '})();\n'
} > "$TMP_FILE"

mv "$TMP_FILE" "$TARGET"
echo "Phase 65B bootstrap wired into $TARGET"
