#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_client_side_operator_guidance_bundle_${STAMP}.txt"
TMP_FILES="$(mktemp)"

find public dashboard/public public/js dashboard/src . \
  \( -path "./.git" -o -path "./node_modules" -o -path "./coverage" \) -prune -o \
  \( -type f \( -name "*.js" -o -name "*.mjs" -o -name "*.cjs" -o -name "*.ts" -o -name "*.tsx" -o -name "*.html" \) \) -print 2>/dev/null | sort -u > "${TMP_FILES}"

python3 - <<'PY'
from pathlib import Path
import re

files = []
with open("/tmp/phase487_bundle_targets.txt", "w") as sink:
    pass

target_paths = []
with open(Path("/tmp").joinpath("phase487_bundle_targets.txt"), "w") as sink:
    for raw in Path("/tmp").joinpath("phase487_unused").parent.joinpath("phase487_unused").parent.glob("*"):
        pass
PY

python3 - <<'PY'
from pathlib import Path
import re

tmp_files = Path("/tmp").joinpath("phase487_bundle_filelist.txt")
PY

cp "${TMP_FILES}" /tmp/phase487_bundle_filelist.txt

python3 - <<'PY'
from pathlib import Path
import re
import sys

filelist = Path("/tmp/phase487_bundle_filelist.txt")
paths = [Path(line.strip()) for line in filelist.read_text().splitlines() if line.strip()]

patched = []
targeted = []

for path in paths:
    try:
        text = path.read_text(errors="ignore")
    except Exception:
        continue

    exact_card = (
        "Awaiting bounded guidance stream" in text
        and "Live operator guidance will appear here when visibility wiring is active" in text
        and "diagnostics/system-health" in text
    )
    has_bad_conf = "Confidence: insufficient" in text or "insufficient<br />" in text or "insufficient<br>" in text

    if exact_card or has_bad_conf:
        targeted.append(str(path))

    original = text

    replacements = [
        ("Confidence: insufficient", "Confidence: limited"),
        ("insufficient<br />", "limited<br />"),
        ("insufficient<br>", "limited<br>"),
        ('"insufficient"', '"limited"'),
        ("'insufficient'", "'limited'"),
        ('`insufficient`', '`limited`'),
        ('surfaceConfidence:"insufficient"', 'surfaceConfidence:"limited"'),
        ("surfaceConfidence:'insufficient'", "surfaceConfidence:'limited'"),
        ('confidence:"insufficient"', 'confidence:"limited"'),
        ("confidence:'insufficient'", "confidence:'limited'"),
        ('confidenceLabel:"insufficient"', 'confidenceLabel:"limited"'),
        ("confidenceLabel:'insufficient'", "confidenceLabel:'limited'"),
        ('return "insufficient";', 'return "limited";'),
        ("return 'insufficient';", "return 'limited';"),
        ('? "insufficient" :', '? "limited" :'),
        ("? 'insufficient' :", "? 'limited' :"),
        (':"insufficient"', ':"limited"'),
        (":'insufficient'", ":'limited'"),
        (': "insufficient"', ': "limited"'),
        (": 'insufficient'", ": 'limited'"),
    ]

    for old, new in replacements:
        text = text.replace(old, new)

    text = re.sub(r'(\bconfidence\b[^=\n:]{0,40}[:=]\s*")insufficient(")', r'\1limited\2', text)
    text = re.sub(r"(\bconfidence\b[^=\n:]{0,40}[:=]\s*')insufficient(')", r"\1limited\2", text)
    text = re.sub(r'(\bconfidenceLabel\b[^=\n:]{0,40}[:=]\s*")insufficient(")', r'\1limited\2', text)
    text = re.sub(r"(\bconfidenceLabel\b[^=\n:]{0,40}[:=]\s*')insufficient(')", r"\1limited\2", text)
    text = re.sub(r'(\bsurfaceConfidence\b[^=\n:]{0,40}[:=]\s*")insufficient(")', r'\1limited\2', text)
    text = re.sub(r"(\bsurfaceConfidence\b[^=\n:]{0,40}[:=]\s*')insufficient(')", r"\1limited\2", text)

    if text != original:
        path.write_text(text)
        patched.append(str(path))

Path("/tmp/phase487_bundle_targets_found.txt").write_text("\n".join(targeted) + ("\n" if targeted else ""))
Path("/tmp/phase487_bundle_targets_patched.txt").write_text("\n".join(patched) + ("\n" if patched else ""))

if not patched:
    sys.exit(2)
PY
PATCH_STATUS=$?

{
  echo "PHASE 487 — PATCH CLIENT-SIDE OPERATOR GUIDANCE BUNDLE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo "patch_status=${PATCH_STATUS}"
  echo

  echo "=== TARGETED FILES ==="
  cat /tmp/phase487_bundle_targets_found.txt 2>/dev/null || true
  echo

  echo "=== PATCHED FILES ==="
  cat /tmp/phase487_bundle_targets_patched.txt 2>/dev/null || true
  echo

  echo "=== REPO CHECK AFTER PATCH ==="
  xargs rg -n -C 3 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence: insufficient|Confidence: limited|Sources: diagnostics/system-health" < "${TMP_FILES}" 2>/dev/null || true
  echo

  echo "=== RESTART / REBUILD ==="
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    docker compose up -d --build 2>&1 || docker-compose up -d --build 2>&1 || true
  fi
  if command -v pm2 >/dev/null 2>&1; then
    pm2 restart all 2>&1 || true
  fi
  echo

  echo "=== SERVED BODY CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "Confidence: insufficient\|Confidence: limited\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" || true
  echo
} > "${OUT}"

rm -f "${TMP_FILES}" /tmp/phase487_bundle_filelist.txt /tmp/phase487_bundle_targets_found.txt /tmp/phase487_bundle_targets_patched.txt

echo "${OUT}"
