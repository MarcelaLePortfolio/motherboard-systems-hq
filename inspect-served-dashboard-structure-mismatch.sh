
#!/usr/bin/env bash

set -euo pipefail

echo "--- served dashboard structural containers ---"

grep -nE 'phase61-workspace-shell|phase61-workspace-grid|phase61-operator-column|phase61-telemetry-column|operator-workspace-card|observational-workspace-card|operator-panels|observational-panels|obs-panel|obs-surface' public/dashboard.html

echo

echo "--- active dashboard layout/style sources ---"

grep -nE 'stylesheet|style id=|phase61_workspace|phase61_tabs|phase487|phase489|phase490|obs-panel|obs-surface|workspace-grid' public/dashboard.html public/css/*.css | head -240

echo

echo "--- compare index structural/style anchors only ---"

diff -u \

  <(grep -nE 'phase61-workspace-shell|phase61-workspace-grid|phase61-operator-column|phase61-telemetry-column|operator-workspace-card|observational-workspace-card|operator-panels|observational-panels|obs-panel|obs-surface|stylesheet|style id=' public/dashboard.html) \

  <(grep -nE 'phase61-workspace-shell|phase61-workspace-grid|phase61-operator-column|phase61-telemetry-column|operator-workspace-card|observational-workspace-card|operator-panels|observational-panels|obs-panel|obs-surface|stylesheet|style id=' public/index.html) \

  || true

echo

echo "--- current git head ---"

git log --oneline -5

