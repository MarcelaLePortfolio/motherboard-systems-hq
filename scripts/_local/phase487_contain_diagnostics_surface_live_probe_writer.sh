#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

TARGET_FILE="docs/phase487_diagnostics_surface_live_probe_output.txt"
RUNTIME_DIR=".runtime/phase487"
mkdir -p "$RUNTIME_DIR"

if [ -f "$TARGET_FILE" ]; then
  TS="$(date +%Y%m%d_%H%M%S)"
  mv "$TARGET_FILE" "$RUNTIME_DIR/phase487_diagnostics_surface_live_probe_output_${TS}.txt"
  echo "Moved existing volatile artifact to runtime sink: $RUNTIME_DIR"
fi

cat > "$TARGET_FILE" <<'STUB'
PHASE 487 NOTICE:
This file is a deprecated artifact sink.

All runtime probe / recovery outputs must NOT be written to docs/.
Use a non-repo runtime path (e.g., .runtime/) instead.

If this file grows, containment has failed.
STUB

echo "Containment stub placed at $TARGET_FILE"
