#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_force_served_confidence_label_sync_${STAMP}.txt"

python3 - <<'PY'
from pathlib import Path
import re
import sys

targets = [
    Path("public/dashboard.html"),
    Path("dashboard/public/dashboard.html"),
    Path("dashboard/src/cognition/operatorGuidance/operatorGuidanceRenderContract.ts"),
    Path("dashboard/src/cognition/operatorGuidance/operatorGuidance.ts"),
    Path("src/cognition/operatorGuidance.live.ts"),
    Path("routes/diagnostics/operatorGuidanceRuntime.js"),
]

patched = []

for path in targets:
    if not path.exists():
        continue
    text = path.read_text(errors="ignore")
    original = text

    replacements = [
        ("Confidence: insufficient", "Confidence: limited"),
        ('>insufficient<', '>limited<'),
        ('"insufficient"', '"limited"'),
        ("'insufficient'", "'limited'"),
        ('"high" | "medium" | "low" | "insufficient"', '"high" | "medium" | "low" | "limited"'),
        ("'high' | 'medium' | 'low' | 'insufficient'", "'high' | 'medium' | 'low' | 'limited'"),
    ]

    for old, new in replacements:
        text = text.replace(old, new)

    text = re.sub(r'(\bconfidence(Label)?\b[^=\n:]*[:=]\s*["\'])insufficient(["\'])', r'\1limited\3', text)
    text = re.sub(r'(\bsurfaceConfidence\b[^=\n:]*[:=]\s*["\'])insufficient(["\'])', r'\1limited\2', text)
    text = re.sub(r'(\breturn\s+["\'])insufficient(["\']\s*;)', r'\1limited\2', text)
    text = re.sub(r'(\?\s*["\'])insufficient(["\']\s*:)', r'\1limited\2', text)

    if text != original:
        path.write_text(text)
        patched.append(str(path))

if not patched:
    raise SystemExit("No operator guidance confidence sync targets patched.")

print("patched_files=" + ",".join(patched))
PY

{
  echo "PHASE 487 — FORCE SERVED CONFIDENCE LABEL SYNC"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== SOURCE CHECK ==="
  rg -n -C 3 "Confidence:|surfaceConfidence|confidence|limited|insufficient|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|diagnostics/system-health" \
    public/dashboard.html \
    dashboard/public/dashboard.html \
    dashboard/src/cognition/operatorGuidance/operatorGuidanceRenderContract.ts \
    dashboard/src/cognition/operatorGuidance/operatorGuidance.ts \
    src/cognition/operatorGuidance.live.ts \
    routes/diagnostics/operatorGuidanceRuntime.js 2>/dev/null || true
  echo

  echo "=== RESTART / REBUILD ==="
  if command -v pm2 >/dev/null 2>&1; then
    pm2 restart all 2>&1 || true
  fi
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    docker compose up -d --build 2>&1 || docker-compose up -d --build 2>&1 || true
  fi
  echo

  echo "=== HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== RUNTIME STRING CHECK ==="
  curl -s http://localhost:8080 | grep -n "Confidence:" || true
  echo
} > "${OUT}"

echo "${OUT}"
