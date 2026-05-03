#!/usr/bin/env bash
set -euo pipefail

python3 - <<'PY'
from pathlib import Path

p = Path("public/dashboard.html")
text = p.read_text()

needle = """  <script>
    console.log("[diag] dashboard static isolation mode active");
  </script>
"""

if "id=\"phase464x-minimal-sentinel\"" in text:
    raise SystemExit(0)

replacement = """  <script>
    console.log("[diag] dashboard static isolation mode active");
  </script>
  <script id="phase464x-minimal-sentinel">
    (() => {
      console.log("[phase464x sentinel] inline script executed");
      console.error("[phase464x sentinel] inline script executed");

      const badge = document.createElement("div");
      badge.id = "phase464x-sentinel-badge";
      badge.textContent = "phase464x sentinel active";
      badge.style.cssText = [
        "position:fixed",
        "top:12px",
        "right:12px",
        "z-index:99999",
        "padding:8px 10px",
        "border-radius:10px",
        "background:#1d4ed8",
        "color:#fff",
        "font:12px/1.4 ui-monospace, SFMono-Regular, Menlo, monospace",
        "border:1px solid rgba(255,255,255,.18)",
        "box-shadow:0 6px 20px rgba(0,0,0,.35)"
      ].join(";");
      document.addEventListener("DOMContentLoaded", () => {
        if (!document.getElementById("phase464x-sentinel-badge")) {
          document.body.appendChild(badge);
        }
        console.log("[phase464x sentinel] DOMContentLoaded");
        console.error("[phase464x sentinel] DOMContentLoaded");
      }, { once: true });
    })();
  </script>
"""

if needle not in text:
    raise SystemExit("dashboard diag script anchor not found")

p.write_text(text.replace(needle, replacement, 1))
PY
