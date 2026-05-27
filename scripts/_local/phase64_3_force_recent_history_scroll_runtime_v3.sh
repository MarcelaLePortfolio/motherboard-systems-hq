#!/usr/bin/env bash
set -euo pipefail

python3 - << 'PY'
from pathlib import Path

path = Path("public/js/phase61_recent_history_wire.js")
text = path.read_text()
original = text

start = text.index("    function buildOwnedShell(key) {")
end = text.index("    function renderEmpty(listEl, message) {", start)

replacement = """    function buildOwnedShell(key) {
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
      probeEl.setAttribute("data-phase61-probe", key);
      probeEl.style.fontSize = "11px";
      probeEl.style.opacity = ".55";
      probeEl.style.padding = "2px 0";
      probeEl.textContent = `probe:${key}:boot`;

      const statusEl = document.createElement("div");
      statusEl.setAttribute("data-phase61-status", key);
      statusEl.style.fontSize = "12px";
      statusEl.style.opacity = ".72";

      const listEl = document.createElement("div");
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

      shell.appendChild(probeEl);
      shell.appendChild(statusEl);
      shell.appendChild(listEl);

      return { shell, probeEl, statusEl, listEl };
    }

    function ensureOwnedCard(card, key) {
      let shell = card.querySelector(`:scope > [data-phase61-shell="${key}"]`);
      if (!shell) {
        card.innerHTML = "";
        const owned = buildOwnedShell(key);
        card.appendChild(owned.shell);
        shell = owned.shell;
      }

      const probeEl = shell.querySelector(`[data-phase61-probe="${key}"]`);
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
    }

"""

text = text[:start] + replacement + text[end:]

if text == original:
    raise SystemExit("no changes applied")

path.write_text(text)
print("patched public/js/phase61_recent_history_wire.js")
PY
