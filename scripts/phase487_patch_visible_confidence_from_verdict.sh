#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_visible_confidence_from_verdict_${STAMP}.txt"

python3 - <<'PY'
from pathlib import Path
import sys

targets = [
    Path("src/cognition/operatorGuidance.live.ts"),
    Path("dashboard/src/cognition/operatorGuidance/operatorGuidance.ts"),
    Path("src/cognition/operatorGuidanceConfidence.ts"),
    Path("src/cognition/operatorGuidanceMapping.ts"),
]

patched = []

for path in targets:
    if not path.exists():
        continue
    text = path.read_text()
    original = text

    replacements = [
        ('"high" | "medium" | "low" | "insufficient"', '"high" | "medium" | "low" | "limited"'),
        ("'high' | 'medium' | 'low' | 'insufficient'", "'high' | 'medium' | 'low' | 'limited'"),
        ('surfaceConfidence: "insufficient"', 'surfaceConfidence: "limited"'),
        ("surfaceConfidence: 'insufficient'", "surfaceConfidence: 'limited'"),
        ('confidence: "insufficient"', 'confidence: "limited"'),
        ("confidence: 'insufficient'", "confidence: 'limited'"),
        ('return "insufficient";', 'return "limited";'),
        ("return 'insufficient';", "return 'limited';"),
        ('? "insufficient" :', '? "limited" :'),
        ("? 'insufficient' :", "? 'limited' :"),
        (': "insufficient"', ': "limited"'),
        (": 'insufficient'", ": 'limited'"),
        ('Confidence: insufficient', 'Confidence: limited'),
    ]

    for old, new in replacements:
        text = text.replace(old, new)

    if text != original:
        path.write_text(text)
        patched.append(str(path))

if not patched:
    print("No visible confidence targets patched; aborting for safety.", file=sys.stderr)
    sys.exit(1)

print("patched_files=" + ",".join(patched))
PY

{
  echo "PHASE 487 — PATCH VISIBLE CONFIDENCE FROM VERDICT"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== PATCHED FILE CHECK ==="
  rg -n -C 3 "surfaceConfidence|Confidence:|limited|insufficient" \
    src/cognition/operatorGuidance.live.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidance.ts \
    src/cognition/operatorGuidanceConfidence.ts \
    src/cognition/operatorGuidanceMapping.ts 2>/dev/null || true
  echo

  echo "=== PM2 RESTART ==="
  pm2 restart all 2>&1 || true
  echo

  echo "=== DOCKER COMPOSE UP ==="
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    docker compose up -d 2>&1 || docker-compose up -d 2>&1 || true
  else
    echo "Docker unavailable; skipping compose up"
  fi
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || echo "localhost:3000 unreachable"
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo
} > "${OUT}"

echo "${OUT}"
