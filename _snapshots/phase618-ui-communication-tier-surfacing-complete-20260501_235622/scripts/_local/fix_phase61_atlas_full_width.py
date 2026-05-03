#!/usr/bin/env python3
from pathlib import Path
import re
import sys

p = Path("public/dashboard.html")
text = p.read_text(encoding="utf-8")

atlas_match = re.search(
    r'(?P<section>\n\s*<section aria-label="Subsystem status"[\s\S]*?</section>\s*(?=\n\s*<div id="phase16-sse-indicator"|'
    r'\n\s*<div id="phase59-compat-roots"|'
    r'\n\s*<script|\n\s*</main>))',
    text,
)
if not atlas_match:
    atlas_match = re.search(
        r'(?P<section>\n\s*<section[\s\S]*?<section id="atlas-status-card"[\s\S]*?</section>\s*</section>)',
        text,
    )

if not atlas_match:
    print("atlas section not found", file=sys.stderr)
    sys.exit(1)

atlas_block = atlas_match.group("section")
text_wo_atlas = text[:atlas_match.start()] + text[atlas_match.end():]

workspace_close = text_wo_atlas.find('\n        </section>\n      </main>')
if workspace_close == -1:
    workspace_close = text_wo_atlas.find('\n      </main>')
if workspace_close == -1:
    print("workspace/main closing anchor not found", file=sys.stderr)
    sys.exit(1)

insert_at = workspace_close
updated = text_wo_atlas[:insert_at] + atlas_block + text_wo_atlas[insert_at:]

updated = updated.replace(
    '<div id="phase61-workspace-grid">',
    '<div id="phase61-workspace-grid">',
    1,
)

style_snippet = """
      #phase61-workspace-shell,
      #phase61-workspace-grid {
        width: 100%;
      }

      #phase61-workspace-grid + section,
      main.phase59-shell > section[aria-label="Subsystem status"] {
        width: 100%;
      }

      main.phase59-shell > section[aria-label="Subsystem status"] {
        grid-column: 1 / -1;
      }

      #atlas-status-card {
        width: 100%;
        max-width: 100%;
      }
"""

if 'main.phase59-shell > section[aria-label="Subsystem status"]' not in updated:
    updated = updated.replace(
        '</style>',
        style_snippet + '\n    </style>',
        1,
    )

p.write_text(updated, encoding="utf-8")
print("atlas full-width fix applied")
