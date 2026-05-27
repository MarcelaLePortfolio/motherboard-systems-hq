#!/usr/bin/env bash
set -euo pipefail

TARGET="public/js/dashboard-bundle-entry.js"
MARKER='/* PHASE65B_TELEMETRY_BOOTSTRAP */'

if grep -Fq "$MARKER" "$TARGET"; then
  echo "Phase 65B bootstrap already wired"
  exit 0
fi

TMP_FILE="$(mktemp)"

cat "$TARGET" > "$TMP_FILE"

cat >> "$TMP_FILE" << 'BLOCK'

/* PHASE65B_TELEMETRY_BOOTSTRAP */
(function () {
  if (typeof document === "undefined") return;
  if (document.querySelector('script[src="/js/telemetry/phase65b_metric_bootstrap.js"]')) return;

  const script = document.createElement("script");
  script.src = "/js/telemetry/phase65b_metric_bootstrap.js";
  script.defer = true;
  document.body.appendChild(script);
})();
BLOCK

mv "$TMP_FILE" "$TARGET"
echo "Phase 65B bootstrap wired into $TARGET"
