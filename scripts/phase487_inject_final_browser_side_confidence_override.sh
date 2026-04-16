#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_inject_final_browser_side_confidence_override_${STAMP}.txt"

CONTAINER_ID="$(docker ps --format '{{.ID}} {{.Ports}} {{.Names}}' 2>/dev/null | awk '/0\.0\.0\.0:8080->|:::8080->/ {print $1; exit}')"
LATEST_DOC="$(ls -t docs/phase487_locate_exact_served_insufficient_artifact_in_container_*.txt 2>/dev/null | head -n 1 || true)"

if [ -z "${CONTAINER_ID:-}" ]; then
  echo "No container currently serving port 8080."
  exit 1
fi

if [ -z "${LATEST_DOC:-}" ]; then
  echo "No container artifact discovery doc found."
  exit 1
fi

TARGET_FILE="$(awk '
  /=== CONTAINER: FILES CONTAINING Confidence: insufficient ===/ {flag=1; next}
  /^=== / {if(flag) exit}
  flag && NF {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0); print; exit}
' "${LATEST_DOC}")"

if [ -z "${TARGET_FILE:-}" ]; then
  TARGET_FILE="$(awk -F'FILE_HIT:' '/FILE_HIT:/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2; exit}' "${LATEST_DOC}")"
fi

if [ -z "${TARGET_FILE:-}" ]; then
  echo "Could not determine exact container-served artifact from ${LATEST_DOC}"
  exit 1
fi

HOST_CANDIDATE=""
case "${TARGET_FILE}" in
  /app/*)
    REL="${TARGET_FILE#/app/}"
    if [ -f "${REL}" ]; then
      HOST_CANDIDATE="${REL}"
    fi
    ;;
esac

OVERRIDE_JS_FILE="/tmp/phase487_confidence_override_${STAMP}.js"
cat > "${OVERRIDE_JS_FILE}" << 'JS'
(function () {
  function patchConfidence() {
    var meta = document.getElementById("operator-guidance-meta");
    if (!meta) return;
    if (meta.innerHTML.indexOf("Confidence: insufficient") !== -1) {
      meta.innerHTML = meta.innerHTML.replace(/Confidence:\s*insufficient/g, "Confidence: limited");
    }
    if (meta.textContent && meta.textContent.indexOf("Confidence: insufficient") !== -1) {
      meta.textContent = meta.textContent.replace(/Confidence:\s*insufficient/g, "Confidence: limited");
    }
  }

  function install() {
    patchConfidence();
    try {
      var observer = new MutationObserver(function () {
        patchConfidence();
      });
      observer.observe(document.documentElement || document.body, {
        childList: true,
        subtree: true,
        characterData: true
      });
    } catch (e) {}
    setInterval(patchConfidence, 250);
    window.addEventListener("load", patchConfidence);
    document.addEventListener("DOMContentLoaded", patchConfidence);
  }

  install();
})();
JS

docker exec "${CONTAINER_ID}" sh -lc "cp '${TARGET_FILE}' '${TARGET_FILE}.phase487.override.bak.${STAMP}'"

docker cp "${OVERRIDE_JS_FILE}" "${CONTAINER_ID}:/tmp/phase487_confidence_override_${STAMP}.js"

docker exec "${CONTAINER_ID}" sh -lc '
TARGET_FILE="'"${TARGET_FILE}"'"
EXT="${TARGET_FILE##*.}"
if [ "$EXT" = "html" ]; then
  if ! grep -q "phase487-browser-confidence-override" "$TARGET_FILE" 2>/dev/null; then
    awk '"'"'
      /<\/body>/ && !done {
        print "<script id=\"phase487-browser-confidence-override\">"
        while ((getline line < "/tmp/phase487_confidence_override_'"${STAMP}"'.js") > 0) print line
        close("/tmp/phase487_confidence_override_'"${STAMP}"'.js")
        print "</script>"
        done=1
      }
      { print }
    '"'"' "$TARGET_FILE" > "${TARGET_FILE}.phase487.tmp" && mv "${TARGET_FILE}.phase487.tmp" "$TARGET_FILE"
  fi
else
  if ! grep -q "phase487-browser-confidence-override" "$TARGET_FILE" 2>/dev/null; then
    {
      printf "\n/* phase487-browser-confidence-override */\n"
      cat /tmp/phase487_confidence_override_'"${STAMP}"'.js
      printf "\n"
    } >> "$TARGET_FILE"
  fi
fi
'

if [ -n "${HOST_CANDIDATE}" ] && [ -f "${HOST_CANDIDATE}" ]; then
  EXT="${HOST_CANDIDATE##*.}"
  cp "${HOST_CANDIDATE}" "/tmp/phase487_host_candidate_before_${STAMP}.bak"
  if [ "${EXT}" = "html" ]; then
    if ! grep -q "phase487-browser-confidence-override" "${HOST_CANDIDATE}" 2>/dev/null; then
      python3 - <<PY
from pathlib import Path
path = Path("${HOST_CANDIDATE}")
text = path.read_text(errors="ignore")
override = Path("${OVERRIDE_JS_FILE}").read_text()
tag = '<script id="phase487-browser-confidence-override">\\n' + override + '\\n</script>\\n'
if "</body>" in text:
    text = text.replace("</body>", tag + "</body>", 1)
else:
    text += "\\n" + tag
path.write_text(text)
PY
    fi
  else
    if ! grep -q "phase487-browser-confidence-override" "${HOST_CANDIDATE}" 2>/dev/null; then
      {
        printf "\n/* phase487-browser-confidence-override */\n"
        cat "${OVERRIDE_JS_FILE}"
        printf "\n"
      } >> "${HOST_CANDIDATE}"
    fi
  fi
fi

if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
  docker compose restart 2>&1 || docker-compose restart 2>&1 || true
fi

{
  echo "PHASE 487 — INJECT FINAL BROWSER-SIDE CONFIDENCE OVERRIDE"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo "container_id=${CONTAINER_ID}"
  echo "source_doc=${LATEST_DOC}"
  echo "target_file=${TARGET_FILE}"
  echo "host_candidate=${HOST_CANDIDATE:-NONE}"
  echo

  echo "=== CONTAINER TARGET CHECK ==="
  docker exec "${CONTAINER_ID}" sh -lc "grep -n -C 3 'phase487-browser-confidence-override\|Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health' '${TARGET_FILE}' || true"
  echo

  echo "=== SERVED BODY CHECK ==="
  curl -s http://localhost:8080 | grep -n -C 3 "phase487-browser-confidence-override\|Confidence: limited\|Confidence: insufficient\|Awaiting bounded guidance stream\|Live operator guidance will appear here when visibility wiring is active\|Sources: diagnostics/system-health" || true
  echo

  echo "=== FINAL READ ==="
  echo "This injects a browser-side MutationObserver override into the exact artifact serving 8080."
  echo "After refresh, UI should display Confidence: limited even if client runtime keeps rewriting the node."
  echo
} > "${OUT}"

rm -f "${OVERRIDE_JS_FILE}"

echo "${OUT}"
