#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_JS="public/js/agent-status-row.js"

cp "$TARGET_JS" "${TARGET_JS}.bak.phase61_5_5"

python3 - << 'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
text = path.read_text()

old = '''  function applyVisual(agentKey, statusValue) {
    const indicator = indicators[agentKey];
    if (!indicator) return;
    const finalStatus = (statusValue || "unknown").toLowerCase();

    indicator.status.textContent = finalStatus;
    indicator.row.className =
      "w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm";
    indicator.bar.className = "inline-block shrink-0";
    indicator.bar.style.width = "8px";
    indicator.bar.style.height = "8px";
    indicator.bar.style.minWidth = "8px";
    indicator.bar.style.minHeight = "8px";
    indicator.bar.style.borderRadius = "999px";
    indicator.bar.style.marginRight = "8px";
    indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";
    indicator.status.className = "text-[11px] font-medium truncate";

    switch (finalStatus) {
      case "online":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.classList.add("bg-emerald-400");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-emerald-300/90");
        break;
      case "offline":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.classList.add("bg-rose-400");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-rose-300/90");
        break;
      case "busy":
      case "warning":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.classList.add("bg-amber-300");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-amber-200/90");
        break;
      default:
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.classList.add("bg-slate-400/70");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-slate-300/75");
        break;
    }
  }
'''

new = '''  function applyVisual(agentKey, statusValue) {
    const indicator = indicators[agentKey];
    if (!indicator) return;
    const finalStatus = (statusValue || "unknown").toLowerCase();

    indicator.status.textContent = finalStatus;
    indicator.row.className =
      "w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm";
    indicator.bar.className = "inline-block shrink-0";
    indicator.bar.style.display = "inline-block";
    indicator.bar.style.width = "8px";
    indicator.bar.style.height = "8px";
    indicator.bar.style.minWidth = "8px";
    indicator.bar.style.minHeight = "8px";
    indicator.bar.style.borderRadius = "999px";
    indicator.bar.style.marginRight = "8px";
    indicator.bar.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";
    indicator.bar.style.background = "rgba(148,163,184,0.8)";
    indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";
    indicator.status.className = "text-[11px] font-medium truncate";

    switch (finalStatus) {
      case "online":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(52,211,153,0.95)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-emerald-300/90");
        break;
      case "offline":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(251,113,133,0.95)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-rose-300/90");
        break;
      case "busy":
      case "warning":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(252,211,77,0.95)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-amber-200/90");
        break;
      default:
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(148,163,184,0.8)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-slate-300/75");
        break;
    }
  }
'''

if old not in text:
    raise SystemExit("expected applyVisual block not found in public/js/agent-status-row.js")

text = text.replace(old, new, 1)
path.write_text(text)
PY

npm run build:dashboard-bundle
