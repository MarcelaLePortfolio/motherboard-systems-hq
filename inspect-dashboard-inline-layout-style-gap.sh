
#!/usr/bin/env bash

set -euo pipefail

echo "--- served dashboard inline style ids ---"

grep -nE '<style id=' public/dashboard.html || true

echo

echo "--- index inline style ids ---"

grep -nE '<style id=' public/index.html || true

echo

echo "--- index style ids missing from served dashboard ---"

tmp_dashboard="$(mktemp)"

tmp_index="$(mktemp)"

trap 'rm -f "$tmp_dashboard" "$tmp_index"' EXIT

grep -oE '<style id="[^"]+"' public/dashboard.html | sort -u > "$tmp_dashboard" || true

grep -oE '<style id="[^"]+"' public/index.html | sort -u > "$tmp_index" || true

comm -13 "$tmp_dashboard" "$tmp_index" || true

echo

echo "--- key layout selectors in index inline styles ---"

grep -nE '#phase61-workspace-grid|#phase61-operator-column|#phase61-telemetry-column|#operator-workspace-card|#observational-workspace-card|#observational-panels|#operator-panels|\.obs-panel|\.obs-surface' public/index.html | head -220 || true

echo

echo "--- key layout selectors in served dashboard inline styles ---"

grep -nE '#phase61-workspace-grid|#phase61-operator-column|#phase61-telemetry-column|#operator-workspace-card|#observational-workspace-card|#observational-panels|#operator-panels|\.obs-panel|\.obs-surface' public/dashboard.html | head -220 || true

echo

echo "--- served dashboard neutralization markers still present ---"

grep -nE 'temporary neutralization|HTML-only layout isolation|bundle.js removed|phase474|phase487' public/dashboard.html | head -120 || true

git log --oneline -5

