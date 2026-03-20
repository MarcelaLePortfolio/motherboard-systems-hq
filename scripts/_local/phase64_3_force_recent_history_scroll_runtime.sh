#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/js/phase61_recent_history_wire.js")
text = path.read_text()
original = text

old_shell = """    function buildOwnedShell(key) {
      const shell = document.createElement("div");
      shell.setAttribute("data-phase61-shell", key);
      shell.style.display = "flex";
      shell.style.flexDirection = "column";
      shell.style.gap = "10px";
      shell.style.minHeight = "320px";

      const probeEl = document.createElement("div");
"""

new_shell = """    function buildOwnedShell(key) {
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
"""

old_list = """      const listEl = document.createElement("div");
      listEl.setAttribute("data-phase61-list", key);
      listEl.style.display = "flex";
      listEl.style.flexDirection = "column";
      listEl.style.gap = "8px";
"""

new_list = """      const listEl = document.createElement("div");
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
"""

old_ensure = """      const probeEl = shell.querySelector(`[data-phase61-probe="${key}"]`);
      const statusEl = shell.querySelector(`[data-phase61-status="${key}"]`);
      const listEl = shell.querySelector(`[data-phase61-list="${key}"]`);
      return { shell, probeEl, statusEl, listEl };
"""

new_ensure = """      const probeEl = shell.querySelector(`[data-phase61-probe="${key}"]`);
      const statusEl = shell.querySelector(`[data-phase61-status="${key}"]`);
      const listEl = shell.querySelector(`[data-phase61-list="${key}"]`);

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

      return { shell, probeEl, statusEl, listEl };
"""

for old, new, label in [
    (old_shell, new_shell, "buildOwnedShell"),
    (old_list, new_list, "listEl"),
    (old_ensure, new_ensure, "ensureOwnedCard"),
]:
    if old not in text:
        raise SystemExit(f"required block not found for {label}")
    text = text.replace(old, new, 1)

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/js/phase61_recent_history_wire.js")
PY
