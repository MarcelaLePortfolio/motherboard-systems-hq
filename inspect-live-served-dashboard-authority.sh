
#!/usr/bin/env bash

set -euo pipefail

REPORT="live-served-dashboard-authority-report.txt"

BASE_URL="${BASE_URL:-http://localhost:8080}"

tmpdir="$(mktemp -d)"

trap 'rm -rf "$tmpdir"' EXIT

curl -sS -D "$tmpdir/dashboard-html.headers" -o "$tmpdir/dashboard-html.body" "$BASE_URL/dashboard.html" || true

curl -sS -D "$tmpdir/dashboard-route.headers" -o "$tmpdir/dashboard-route.body" "$BASE_URL/dashboard" || true

{

  echo "LIVE SERVED DASHBOARD AUTHORITY REPORT"

  echo

  echo "--- current head ---"

  git log --oneline -5

  echo

  echo "--- local vs served byte hashes ---"

  shasum -a 256 public/dashboard.html "$tmpdir/dashboard-html.body" "$tmpdir/dashboard-route.body" 2>/dev/null || true

  echo

  echo "--- local vs served byte equality ---"

  diff -q public/dashboard.html "$tmpdir/dashboard-html.body" || true

  diff -q public/dashboard.html "$tmpdir/dashboard-route.body" || true

  echo

  echo "--- served /dashboard.html headers ---"

  cat "$tmpdir/dashboard-html.headers"

  echo

  echo "--- served /dashboard route headers ---"

  cat "$tmpdir/dashboard-route.headers"

  echo

  echo "--- served dashboard key anchors ---"

  grep -nE 'phase61-workspace-shell|phase61-atlas-band|atlas-status-card|Telemetry Console|Execution Inspector|id="recentTasks"|dashboard-bundle-entry|phase61_tabs_workspace|phase530_visible_panels_bridge' "$tmpdir/dashboard-html.body" || true

  echo

  echo "--- local dashboard key anchors ---"

  grep -nE 'phase61-workspace-shell|phase61-atlas-band|atlas-status-card|Telemetry Console|Execution Inspector|id="recentTasks"|dashboard-bundle-entry|phase61_tabs_workspace|phase530_visible_panels_bridge' public/dashboard.html || true

  echo

  echo "--- workspace shell counts local vs served ---"

  printf "local phase61-workspace-shell count: "

  grep -c 'id="phase61-workspace-shell"' public/dashboard.html || true

  printf "served phase61-workspace-shell count: "

  grep -c 'id="phase61-workspace-shell"' "$tmpdir/dashboard-html.body" || true

} | tee "$REPORT"

git add inspect-live-served-dashboard-authority.sh "$REPORT"

git commit -m "Inspect live served dashboard authority" || true

git push

