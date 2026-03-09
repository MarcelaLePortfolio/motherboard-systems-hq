#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 <<'PY'
from pathlib import Path

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

text = text.replace(
"""      <section id="phase61-workspace-shell" aria-labelledby="phase61-workspace-heading" class="space-y-4">
        <div class="flex items-center justify-between">
          <h2 id="phase61-workspace-heading" class="text-xs uppercase tracking-[0.24em] text-gray-400">
            Operator Workspace
          </h2>
        </div>

        <div id="phase61-workspace-grid">""",
"""      <section id="phase61-workspace-shell" aria-label="Workspace region" class="space-y-4">
        <div id="phase61-workspace-grid">""",
1)

text = text.replace(
'<section id="phase61-workspace-shell" aria-label="Workspace region" class="space-y-4">',
'<section id="phase61-workspace-shell" class="space-y-4">',
1)

p.write_text(text, encoding="utf-8")
print("workspace header removed")
PY
