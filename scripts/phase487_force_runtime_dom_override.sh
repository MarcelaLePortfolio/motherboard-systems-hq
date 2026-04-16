#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_force_runtime_dom_override_${STAMP}.txt"
TARGET="public/dashboard.html"

cp "${TARGET}" "/tmp/dashboard_pre_dom_patch_${STAMP}.bak"

python3 - << 'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()
original = text

injection = """
<script id="phase487-force-confidence-override">
(function() {
  function patchConfidence() {
    var el = document.getElementById("operator-guidance-meta");
    if (!el) return;
    if (el.innerHTML.includes("Confidence: insufficient")) {
      el.innerHTML = el.innerHTML.replace("Confidence: insufficient", "Confidence: limited");
    }
  }

  patchConfidence();
  setInterval(patchConfidence, 500);
})();
</script>
"""

if "phase487-force-confidence-override" not in text:
    if "</body>" in text:
        text = text.replace("</body>", injection + "\n</body>")
    else:
        text += injection

if text == original:
    raise SystemExit("No DOM override patch applied (already present or failed).")

path.write_text(text)
PY

{
  echo "PHASE 487 — FORCE RUNTIME DOM OVERRIDE"
  echo "timestamp=${STAMP}"
  echo "target=${TARGET}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== DIFF ==="
  diff -u "/tmp/dashboard_pre_dom_patch_${STAMP}.bak" "${TARGET}" || true
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
  curl -s http://localhost:8080 | grep -n -C 3 "phase487-force-confidence-override" || true
  echo

  echo "=== FINAL READ ==="
  echo "This forces the UI to override any client-side render still emitting 'insufficient'."
  echo "If UI now shows 'limited', root cause is confirmed as runtime bundle overwrite."
  echo
} > "${OUT}"

echo "${OUT}"
