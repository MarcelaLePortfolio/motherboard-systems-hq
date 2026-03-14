#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path
import re

path = Path("public/js/phase61_recent_history_wire.js")
text = path.read_text()
original = text

text, c1 = re.subn(
    r'''(?ms)^(\s*function buildOwnedShell\(key\) \{\n\s*const shell = document\.createElement\("div"\);\n\s*shell\.setAttribute\("data-phase61-shell", key\);\n\s*shell\.style\.display = "flex";\n\s*shell\.style\.flexDirection = "column";\n\s*shell\.style\.gap = "10px";\n)\s*shell\.style\.minHeight = "320px";\n''',
    r'''\1      shell.style.flex = "1 1 auto";
      shell.style.minHeight = "0";
      shell.style.height = "100%";
      shell.style.overflow = "hidden";
''',
    text,
    count=1,
)

text, c2 = re.subn(
    r'''(?ms)^(\s*const listEl = document\.createElement\("div"\);\n\s*listEl\.setAttribute\("data-phase61-list", key\);\n\s*listEl\.style\.display = "flex";\n\s*listEl\.style\.flexDirection = "column";\n\s*listEl\.style\.gap = "8px";\n)''',
    r'''\1      listEl.style.flex = "1 1 auto";
      listEl.style.minHeight = "0";
      listEl.style.height = "100%";
      listEl.style.overflowY = "auto";
      listEl.style.overflowX = "hidden";
      listEl.style.paddingRight = "4px";
''',
    text,
    count=1,
)

text, c3 = re.subn(
    r'''(?ms)(\s*const probeEl = shell\.querySelector\(`$begin:math:display$data\-phase61\-probe\=\"\\\$\\\{key\\\}\"$end:math:display$`\);\n\s*const statusEl = shell\.querySelector\(`$begin:math:display$data\-phase61\-status\=\"\\\$\\\{key\\\}\"$end:math:display$`\);\n\s*const listEl = shell\.querySelector\(`$begin:math:display$data\-phase61\-list\=\"\\\$\\\{key\\\}\"$end:math:display$`\);\n)(\s*return \{ shell, probeEl, statusEl, listEl \};)''',
    r'''\1
      shell.style.flex = "1 1 auto";
      shell.style.minHeight = "0";
      shell.style.height = "100%";
      shell.style.overflow = "hidden";

      if (listEl) {
        listEl.style.flex = "1 1 auto";
        listEl.style.minHeight = "0";
        listEl.style.height = "100%";
        listEl.style.overflowY = "auto";
        listEl.style.overflowX = "hidden";
        listEl.style.paddingRight = "4px";
      }

\2''',
    text,
    count=1,
)

if (c1, c2, c3) != (1, 1, 1):
    raise SystemExit(f"patch counts unexpected: buildOwnedShell={c1} listEl={c2} ensureOwnedCard={c3}")

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/js/phase61_recent_history_wire.js")
PY
