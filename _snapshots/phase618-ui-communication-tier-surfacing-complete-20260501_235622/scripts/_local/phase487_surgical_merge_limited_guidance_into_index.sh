#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p docs

REPORT="docs/phase487_surgical_merge_limited_guidance_into_index.txt"

python3 - << 'PY'
from pathlib import Path
import re
import shutil

index_path = Path("public/index.html")
dashboard_path = Path("public/dashboard.html")
backup_path = Path("public/index.html.phase487_pre_surgical_guidance_merge.bak")

index = index_path.read_text(encoding="utf-8")
dashboard = dashboard_path.read_text(encoding="utf-8")

shutil.copy2(index_path, backup_path)

old_meta = "Confidence: insufficient<br />"
new_meta = '<span>Confidence: limited</span><br><button id="phase493-view-reasoning" style="margin-top:6px;font-size:12px;opacity:0.8;">View reasoning</button><br>'

if old_meta in index:
    index = index.replace(old_meta, new_meta, 1)

marker = "<!-- PHASE 493 REASONING MODAL -->"
if marker not in index:
    start = dashboard.find(marker)
    end = dashboard.rfind("</body>")
    if start == -1 or end == -1 or end <= start:
        raise SystemExit("Could not extract PHASE 493+ bundle from public/dashboard.html")
    bundle = dashboard[start:end].rstrip() + "\n\n"
    if "</body>" not in index:
        raise SystemExit("Could not find </body> in public/index.html")
    index = index.replace("</body>", bundle + "</body>", 1)

index_path.write_text(index, encoding="utf-8")
print(f"wrote {index_path}")
print(f"backup {backup_path}")
PY

{
  echo "PHASE 487 — SURGICAL MERGE LIMITED GUIDANCE INTO INDEX"
  echo "Timestamp: $(date)"
  echo "========================================"
  echo

  echo "[1] BACKUP"
  ls -lah public/index.html.phase487_pre_surgical_guidance_merge.bak 2>/dev/null || true
  echo

  echo "[2] INDEX GUIDANCE BLOCK AFTER SURGICAL MERGE"
  nl -ba public/index.html | sed -n '316,336p'
  echo

  echo "[3] INDEX PHASE493/494/495/496/497/498/499/509 MARKERS"
  grep -nE 'PHASE 493|PHASE 494|PHASE 495|PHASE 496|PHASE 497|PHASE 498|PHASE 499|PHASE 509|guidance_availability|Computed Confidence|Confidence: limited|View reasoning' public/index.html || true
  echo

  echo "[4] LIVE ROOT CONFIDENCE SNAPSHOT"
  curl -s http://localhost:3000 | grep -n "Confidence:" | head -n 20 || true
  echo

  echo "SURGICAL MERGE COMPLETE"
} > "$REPORT"

sed -n '1,260p' "$REPORT"
