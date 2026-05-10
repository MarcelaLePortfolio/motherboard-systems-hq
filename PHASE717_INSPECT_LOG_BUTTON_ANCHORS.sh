
#!/usr/bin/env bash

set -euo pipefail

echo "===== PHASE 717 INSPECT LOG BUTTON ANCHORS ====="

echo ""

echo "[1] Git checkpoint"

git status --short

git log --oneline --decorate -5

echo ""

echo "[2] Locate inspect detail / trace button anchors"

grep -R "Inspect Details\|Inspect Trace\|inspect details\|inspect trace\|data-.*inspect\|details chip\|trace chip" -n public/js server app \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  | head -120

echo ""

echo "[3] Recent Logs references"

grep -R "Recent Logs\|recent logs\|logs\|log" -n public/js server app \

  --exclude-dir=node_modules \

  --exclude-dir=.git \

  --exclude-dir=.next \

  | head -120

echo ""

echo "===== INSPECTION COMPLETE ====="

