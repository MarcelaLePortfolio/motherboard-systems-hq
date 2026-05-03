#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_JS="public/js/agent-status-row.js"

cp "$TARGET_JS" "${TARGET_JS}.bak.phase61_5_5b"

python3 - << 'PY'
from pathlib import Path
import re

path = Path("public/js/agent-status-row.js")
text = path.read_text()

if 'indicator.bar.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";' in text and 'indicator.bar.style.background = "rgba(52,211,153,0.95)";' in text:
    print("agent-status-row.js already contains inline dot styling")
    raise SystemExit(0)

text = text.replace(
    'indicator.bar.className = "inline-block w-2 h-2 rounded-full shrink-0";',
    'indicator.bar.className = "inline-block shrink-0";'
)

text = text.replace(
    'indicator.bar.className = "inline-block shrink-0";',
    '''indicator.bar.className = "inline-block shrink-0";
    indicator.bar.style.display = "inline-block";
    indicator.bar.style.width = "8px";
    indicator.bar.style.height = "8px";
    indicator.bar.style.minWidth = "8px";
    indicator.bar.style.minHeight = "8px";
    indicator.bar.style.borderRadius = "999px";
    indicator.bar.style.marginRight = "8px";
    indicator.bar.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";
    indicator.bar.style.background = "rgba(148,163,184,0.8)";''',
    1
)

replacements = {
    'indicator.bar.classList.add("bg-emerald-400");': 'indicator.bar.style.background = "rgba(52,211,153,0.95)";',
    'indicator.bar.classList.add("bg-rose-400");': 'indicator.bar.style.background = "rgba(251,113,133,0.95)";',
    'indicator.bar.classList.add("bg-amber-300");': 'indicator.bar.style.background = "rgba(252,211,77,0.95)";',
    'indicator.bar.classList.add("bg-slate-400/70");': 'indicator.bar.style.background = "rgba(148,163,184,0.8)";',
}
for old, new in replacements.items():
    text = text.replace(old, new)

if 'indicator.bar.style.background = "rgba(52,211,153,0.95)";' not in text:
    raise SystemExit("failed to inject online dot background style")
if 'indicator.bar.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";' not in text:
    raise SystemExit("failed to inject inline dot base styling")

path.write_text(text)
print("agent-status-row.js patched successfully")
PY

npm run build:dashboard-bundle
