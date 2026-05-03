#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
BASE_COMMIT="b89d5538"

echo "Restoring Phase 489 UI baseline from commit: $BASE_COMMIT"

# Restore the exact front-end state from the last known good Phase 489 UI baseline
git restore --source="$BASE_COMMIT" -- \
  public/index.html \
  public/js/phase61_tabs_workspace.js \
  public/js/phase61_recent_history_wire.js \
  public/js/dashboard-graph.js \
  public/js/phase457_restore_task_panels.js \
  public/js/operatorGuidance.sse.js

# Remove all Phase 490 experimental layout/runtime files
rm -f public/js/phase490_measured_panel_height_sync.js
rm -f public/js/phase490_height_diagnostic_overlay.js
rm -f scripts/_local/phase490_restore_last_known_operator_stability.py
rm -f scripts/_local/phase490_restore_pre_regression_layout.sh
rm -f scripts/_local/phase490_remove_height_diagnostic_overlay.py
rm -f scripts/_local/phase490_force_real_height_contract.py
rm -f scripts/_local/phase490_apply_height_contract.py
rm -f scripts/_local/phase490_force_telemetry_cards_to_css_var.py
rm -f scripts/_local/phase490_mount_height_diagnostic_overlay.py
rm -f scripts/_local/phase490_mount_measured_panel_height_sync.py
rm -f scripts/_local/phase490_make_task_activity_scroll.py

python3 - <<'PY'
from pathlib import Path
import re

p = Path("public/index.html")
text = p.read_text()

# Remove any lingering Phase 490 script mounts
text = re.sub(r'^\s*<script defer src="js/phase490_[^"]+"></script>\s*\n?', '', text, flags=re.M)

# Remove any lingering Phase 490 style blocks
text = re.sub(r'<style id="phase490-[^"]+">.*?</style>\s*', '', text, flags=re.S)

p.write_text(text)
print("Cleaned lingering Phase 490 mounts/styles from public/index.html")
PY

echo "Phase 489 UI baseline restored."
