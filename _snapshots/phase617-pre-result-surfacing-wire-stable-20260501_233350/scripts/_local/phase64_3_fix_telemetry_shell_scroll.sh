#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/js/phase61_recent_history_wire.js")
text = path.read_text()
original = text

old = """    function buildOwnedShell(key) {
      const shell = document.createElement("div");
      shell.setAttribute("data-phase61-shell", key);
      shell.style.display = "flex";
      shell.style.flexDirection = "column";
      shell.style.gap = "10px";
      shell.style.minHeight = "320px";

      const probeEl = document.createElement("div");
"""

new = """    function buildOwnedShell(key) {
      const shell = document.createElement("div");
      shell.setAttribute("data-phase61-shell", key);
      shell.style.display = "flex";
      shell.style.flexDirection = "column";
      shell.style.gap = "10px";
      shell.style.flex = "1 1 auto";
      shell.style.minHeight = "0";
      shell.style.overflow = "hidden";

      const probeEl = document.createElement("div");
"""

if old not in text:
    raise SystemExit("required buildOwnedShell block not found")

text = text.replace(old, new, 1)

old2 = """      const listEl = document.createElement("div");
      listEl.setAttribute("data-phase61-list", key);
      listEl.style.display = "flex";
      listEl.style.flexDirection = "column";
      listEl.style.gap = "8px";
"""

new2 = """      const listEl = document.createElement("div");
      listEl.setAttribute("data-phase61-list", key);
      listEl.style.display = "flex";
      listEl.style.flexDirection = "column";
      listEl.style.gap = "8px";
      listEl.style.flex = "1 1 auto";
      listEl.style.minHeight = "0";
      listEl.style.overflowY = "auto";
      listEl.style.paddingRight = "4px";
"""

if old2 not in text:
    raise SystemExit("required listEl block not found")

text = text.replace(old2, new2, 1)

if text == original:
    print("no changes needed")
else:
    path.write_text(text)
    print("patched public/js/phase61_recent_history_wire.js")
PY
