#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

# Target: docs/phase487_port_recovery_probe_output.txt (high-confidence volatile writer)
TARGET_FILE="docs/phase487_port_recovery_probe_output.txt"

# Create local runtime (non-repo) sink
RUNTIME_DIR=".runtime/phase487"
mkdir -p "$RUNTIME_DIR"

# Move existing file out of docs if present
if [ -f "$TARGET_FILE" ]; then
  TS="$(date +%Y%m%d_%H%M%S)"
  mv "$TARGET_FILE" "$RUNTIME_DIR/phase487_port_recovery_probe_output_${TS}.txt"
  echo "Moved existing volatile artifact to runtime sink."
fi

# Create a stub file to prevent accidental recreation with large content
cat > "$TARGET_FILE" <<'STUB'
PHASE 487 NOTICE:
This file is a deprecated artifact sink.

All runtime probe / recovery outputs must NOT be written to docs/.
Use a non-repo runtime path (e.g., .runtime/) instead.

If this file grows, containment has failed.
STUB

echo "Containment stub placed at $TARGET_FILE"
