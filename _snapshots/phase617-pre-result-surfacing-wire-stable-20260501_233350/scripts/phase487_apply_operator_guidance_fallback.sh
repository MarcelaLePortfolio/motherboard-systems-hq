#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — APPLY OPERATOR GUIDANCE FALLBACK"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean."
  git status --short
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

targets = [Path("public/dashboard.html"), Path("public/index.html")]

block = r'''<script id="phase487-operator-guidance-fallback">
(function () {
  async function safeJson(url) {
    try {
      const res = await fetch(url, { cache: "no-store" });
      if (!res.ok) return null;
      return await res.json();
    } catch (_) {
      return null;
    }
  }

  function setGuidance(text, metaText) {
    const response = document.getElementById("operator-guidance-response");
    const meta = document.getElementById("operator-guidance-meta");
    if (response) {
      response.textContent = text;
      response.style.whiteSpace = "pre-wrap";
    }
    if (meta) {
      meta.textContent = metaText;
    }
  }

  function extractGuidanceText(data) {
    if (!data || typeof data !== "object") return null;
    if (typeof data.guidance === "string" && data.guidance.trim()) return data.guidance.trim();
    if (data.guidance && typeof data.guidance === "object") {
      for (const key of ["summary", "message", "text", "content", "body", "note"]) {
        if (typeof data.guidance[key] === "string" && data.guidance[key].trim()) {
          return data.guidance[key].trim();
        }
      }
    }
    for (const key of ["summary", "message", "text", "content", "body", "situationSummary"]) {
      if (typeof data[key] === "string" && data[key].trim()) return data[key].trim();
    }
    return null;
  }

  async function refreshOperatorGuidance() {
    const guidanceData = await safeJson("/api/guidance");
    if (guidanceData && guidanceData.guidance_available === true) {
      const text = extractGuidanceText(guidanceData) || "Live guidance available.";
      setGuidance(text, "Sources: /api/guidance");
      return;
    }

    const systemHealth = await safeJson("/diagnostics/system-health");
    const fallbackText =
      extractGuidanceText(systemHealth) ||
      "System stable. No active guidance stream.";
    setGuidance(fallbackText, "Sources: diagnostics/system-health (fallback)");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refreshOperatorGuidance, { once: true });
  } else {
    refreshOperatorGuidance();
  }
})();
</script>
'''

for path in targets:
    text = path.read_text()
    start = text.find('<script id="phase487-operator-guidance-fallback">')
    if start != -1:
        end = text.find('</script>', start)
        if end == -1:
            raise SystemExit(f"ERROR: malformed existing fallback block in {path}")
        end += len('</script>')
        text = text[:start] + block + text[end:]
    else:
        anchor = '</body>'
        idx = text.rfind(anchor)
        if idx == -1:
            raise SystemExit(f"ERROR: could not find </body> in {path}")
        text = text[:idx] + block + "\n" + text[idx:]
    path.write_text(text)
    print(f"PATCHED: {path}")
PY

git add public/dashboard.html public/index.html
git commit -m "PHASE 487: add operator guidance fallback to diagnostics system health"
git push

docker compose up -d --build

curl -s http://localhost:8080 | rg -n "phase487-operator-guidance-fallback|operator-guidance-response|operator-guidance-meta" -n
curl -s http://localhost:8080/api/guidance
curl -s http://localhost:8080/diagnostics/system-health
