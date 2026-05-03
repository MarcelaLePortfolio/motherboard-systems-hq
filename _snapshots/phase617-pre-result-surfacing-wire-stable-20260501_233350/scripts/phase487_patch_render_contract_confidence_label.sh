#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

TARGET="dashboard/src/cognition/operatorGuidance/operatorGuidanceRenderContract.ts"
STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_render_contract_confidence_label_${STAMP}.txt"

if [ ! -f "${TARGET}" ]; then
  echo "Missing target file: ${TARGET}"
  exit 1
fi

cp "${TARGET}" "/tmp/operatorGuidanceRenderContract.${STAMP}.bak"

python3 - <<'PY'
from pathlib import Path

path = Path("dashboard/src/cognition/operatorGuidance/operatorGuidanceRenderContract.ts")
text = path.read_text()
original = text

replacements = [
    ('"high" | "medium" | "low" | "insufficient"', '"high" | "medium" | "low" | "limited"'),
    ("'high' | 'medium' | 'low' | 'insufficient'", "'high' | 'medium' | 'low' | 'limited'"),
    ('["high", "medium", "low", "insufficient"]', '["high", "medium", "low", "limited"]'),
    ("['high', 'medium', 'low', 'insufficient']", "['high', 'medium', 'low', 'limited']"),
    ('surfaceConfidence: "insufficient"', 'surfaceConfidence: "limited"'),
    ("surfaceConfidence: 'insufficient'", "surfaceConfidence: 'limited'"),
    ('confidence: "insufficient"', 'confidence: "limited"'),
    ("confidence: 'insufficient'", "confidence: 'limited'"),
    ('confidenceLabel: "insufficient"', 'confidenceLabel: "limited"'),
    ("confidenceLabel: 'insufficient'", "confidenceLabel: 'limited'"),
    ('return "insufficient";', 'return "limited";'),
    ("return 'insufficient';", "return 'limited';"),
    ('=> "insufficient"', '=> "limited"'),
    ("=> 'insufficient'", "=> 'limited'"),
    ('? "insufficient" :', '? "limited" :'),
    ("? 'insufficient' :", "? 'limited' :"),
    (': "insufficient"', ': "limited"'),
    (": 'insufficient'", ": 'limited'"),
    ('=== "insufficient"', '=== "limited"'),
    ("=== 'insufficient'", "=== 'limited'"),
    ('== "insufficient"', '== "limited"'),
    ("== 'insufficient'", "== 'limited'"),
    ('Confidence: insufficient', 'Confidence: limited'),
]

for old, new in replacements:
    text = text.replace(old, new)

if text == original:
    raise SystemExit("No patchable insufficient confidence render found in dashboard render contract.")

path.write_text(text)
PY

{
  echo "PHASE 487 — PATCH RENDER CONTRACT CONFIDENCE LABEL"
  echo "timestamp=${STAMP}"
  echo "target=${TARGET}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== DIFF ==="
  diff -u "/tmp/operatorGuidanceRenderContract.${STAMP}.bak" "${TARGET}" || true
  echo

  echo "=== TARGET CHECK ==="
  rg -n -C 4 "surfaceConfidence|confidence|confidenceLabel|limited|insufficient|Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active" "${TARGET}" || true
  echo

  echo "=== PM2 RESTART ==="
  pm2 restart all 2>&1 || true
  echo

  echo "=== DOCKER COMPOSE UP ==="
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    docker compose up -d --build 2>&1 || docker-compose up -d --build 2>&1 || true
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
