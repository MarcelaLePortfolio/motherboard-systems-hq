#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path
import re

path = Path("public/js/phase61_recent_history_wire.js")
text = path.read_text()
original = text

shell_pattern = re.compile(
    r'''(?P<block>function buildOwnedShell\(key\) \{\n(?:.*\n)*?      const probeEl = document\.createElement\("div"\);\n)''',
    re.MULTILINE
)

list_pattern = re.compile(
    r'''(?P<block>      const listEl = document\.createElement\("div"\);\n      listEl\.setAttribute\("data-phase61-list", key\);\n      listEl\.style\.display = "flex";\n      listEl\.style\.flexDirection = "column";\n      listEl\.style\.gap = "8px";\n)''',
    re.MULTILINE
)

shell_replacement = '''function buildOwnedShell(key) {
      const shell = document.createElement("div");
      shell.setAttribute("data-phase61-shell", key);
      shell.style.display = "flex";
      shell.style.flexDirection = "column";
      shell.style.gap = "10px";
      shell.style.flex = "1 1 auto";
      shell.style.minHeight = "0";
      shell.style.height = "100%";
      shell.style.overflow = "hidden";

      const probeEl = document.createElement("div");
'''

list_replacement = '''      const listEl = document.createElement("div");
      listEl.setAttribute("data-phase61-list", key);
      listEl.style.display = "flex";
      listEl.style.flexDirection = "column";
      listEl.style.gap = "8px";
      listEl.style.flex = "1 1 auto";
      listEl.style.minHeight = "0";
      listEl.style.height = "100%";
      listEl.style.overflowY = "auto";
      listEl.style.overflowX = "hidden";
      listEl.style.paddingRight = "4px";
'''

text, shell_count = shell_pattern.subn(shell_replacement, text, count=1)
text, list_count = list_pattern.subn(list_replacement, text, count=1)

if shell_count != 1:
    raise SystemExit(f"failed to patch buildOwnedShell block exactly once (count={shell_count})")
if list_count != 1:
    raise SystemExit(f"failed to patch listEl block exactly once (count={list_count})")

path.write_text(text)
print("patched public/js/phase61_recent_history_wire.js")
PY
