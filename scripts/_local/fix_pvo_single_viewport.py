#!/usr/bin/env python3
import re
from pathlib import Path

P = Path("public/dashboard.html")
s = P.read_text(encoding="utf-8", errors="replace")

# Match the entire PVO card section and rewrite its inner HTML to a single viewport.
m = re.search(
    r'(<section\b[^>]*\bid=["\']project-visual-output-card["\'][^>]*>)(.*?)(</section>)',
    s,
    flags=re.IGNORECASE | re.DOTALL,
)
if not m:
    raise SystemExit("ERROR: could not find section#project-visual-output-card in public/dashboard.html")

open_tag, inner, close_tag = m.group(1), m.group(2), m.group(3)

canonical_inner = r'''
          <header class="flex items-center justify-between mb-3 border-b border-gray-700 pb-2">
            <h2 class="text-xl font-semibold">Project Visual Output</h2>
            <span class="text-xs uppercase tracking-wide text-indigo-300/80">Viewport</span>
          </header>

          <div
            id="project-visual-output"
            class="project-viewport-inner bg-black/60 rounded-2xl border border-gray-800 min-h-[320px] p-4 overflow-auto flex items-center justify-center"
            style="min-height:320px"
          >
            <p class="text-sm text-gray-400 italic text-center px-6">
              No active project output yet. When a build or demo is running, this screen can display diagrams, previews, or other visual artifacts.
            </p>
          </div>
'''.strip("\n")

new_section = open_tag + "\n" + canonical_inner + "\n        " + close_tag

s2 = s[: m.start()] + new_section + s[m.end() :]

# Hard guardrail: ensure only ONE id="project-visual-output" exists
if len(re.findall(r'\bid=["\']project-visual-output["\']', s2, flags=re.IGNORECASE)) != 1:
    raise SystemExit("ERROR: post-write guardrail failed (project-visual-output id count != 1)")

P.write_text(s2, encoding="utf-8")
print("OK: PVO card normalized to a single viewport.")
