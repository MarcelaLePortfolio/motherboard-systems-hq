#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
text = path.read_text()

if "const agentReportedState = Object.create(null);" not in text:
    text = text.replace(
        '  const indicators = {};\n  const agentActivityAt = Object.create(null);\n  const ACTIVE_WINDOW_MS = 60 * 1000;\n  const activeAgentsMetricEl = document.getElementById("metric-agents");\n',
        '  const indicators = {};\n  const agentActivityAt = Object.create(null);\n  const agentReportedState = Object.create(null);\n  const ACTIVE_WINDOW_MS = 60 * 1000;\n  const activeAgentsMetricEl = document.getElementById("metric-agents");\n',
        1,
    )

if "function formatAge(ms)" not in text:
    text = text.replace(
        '  function refreshActiveAgentsMetric() {\n',
        '  function formatAge(ms) {\n'
        '    if (!Number.isFinite(ms) || ms < 0) return "0s";\n'
        '    const totalSeconds = Math.floor(ms / 1000);\n'
        '    if (totalSeconds < 60) return `${totalSeconds}s`;\n'
        '    const totalMinutes = Math.floor(totalSeconds / 60);\n'
        '    if (totalMinutes < 60) return `${totalMinutes}m`;\n'
        '    return `${Math.floor(totalMinutes / 60)}h`;\n'
        '  }\n\n'
        '  function refreshActiveAgentsMetric() {\n',
        1,
    )

if "function getAgentPresentation(agentKey, reportedStatus)" not in text:
    text = text.replace(
        '  setMetricText(activeAgentsMetricEl, "—");\n',
        '  function getAgentPresentation(agentKey, reportedStatus) {\n'
        '    const reported = String(reportedStatus || "").trim();\n'
        '    const normalized = reported.toLowerCase();\n'
        '    const at = parseTimestamp(agentActivityAt[agentKey]);\n\n'
        '    if (at == null) {\n'
        '      return {\n'
        '        kind: "unknown",\n'
        '        label: reported || "unknown",\n'
        '      };\n'
        '    }\n\n'
        '    const ageMs = Math.max(0, Date.now() - at);\n'
        '    const ageLabel = formatAge(ageMs);\n\n'
        '    if (ageMs > ACTIVE_WINDOW_MS) {\n'
        '      return {\n'
        '        kind: "stale",\n'
        '        label: `stale · ${ageLabel} ago`,\n'
        '      };\n'
        '    }\n\n'
        '    if (\n'
        '      normalized.includes("error") ||\n'
        '      normalized.includes("failed") ||\n'
        '      normalized.includes("offline")\n'
        '    ) {\n'
        '      return {\n'
        '        kind: "error",\n'
        '        label: `${reported || "error"} · ${ageLabel} ago`,\n'
        '      };\n'
        '    }\n\n'
        '    if (normalized && normalized !== "unknown") {\n'
        '      return {\n'
        '        kind: "active",\n'
        '        label: `${reported} · ${ageLabel} ago`,\n'
        '      };\n'
        '    }\n\n'
        '    return {\n'
        '      kind: "active",\n'
        '      label: `active · ${ageLabel} ago`,\n'
        '    };\n'
        '  }\n\n'
        '  setMetricText(activeAgentsMetricEl, "—");\n',
        1,
    )

start = text.find('  function classifyStatus(statusString) {')
end = text.find('  Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));\n')
if start != -1 and end != -1:
    replacement = (
        '  function applyVisual(agentKey, statusString) {\n'
        '    const indicator = indicators[agentKey];\n'
        '    if (!indicator) return;\n\n'
        '    agentReportedState[agentKey] = String(statusString || agentReportedState[agentKey] || "unknown");\n\n'
        '    const presentation = getAgentPresentation(agentKey, agentReportedState[agentKey]);\n'
        '    const kind = presentation.kind;\n'
        '    indicator.status.textContent = presentation.label;\n\n'
        '    indicator.row.className =\n'
        '      "w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm";\n\n'
        '    indicator.emoji.className = "inline-flex items-center justify-center shrink-0";\n'
        '    indicator.emoji.textContent = AGENT_EMOJI[agentKey] || "•";\n'
        '    indicator.emoji.style.display = "inline-flex";\n'
        '    indicator.emoji.style.width = "18px";\n'
        '    indicator.emoji.style.minWidth = "18px";\n'
        '    indicator.emoji.style.height = "18px";\n'
        '    indicator.emoji.style.minHeight = "18px";\n'
        '    indicator.emoji.style.fontSize = "14px";\n'
        '    indicator.emoji.style.lineHeight = "1";\n'
        '    indicator.emoji.style.background = "transparent";\n'
        '    indicator.emoji.style.borderRadius = "0";\n'
        '    indicator.emoji.style.boxShadow = "none";\n'
        '    indicator.emoji.style.marginRight = "0";\n\n'
        '    indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";\n'
        '    indicator.status.className = "text-[11px] font-medium truncate";\n\n'
        '    switch (kind) {\n'
        '      case "active":\n'
        '        indicator.row.classList.add("bg-gray-900", "border-gray-700");\n'
        '        indicator.label.classList.add("text-slate-100");\n'
        '        indicator.status.classList.add("text-emerald-300/90");\n'
        '        break;\n'
        '      case "error":\n'
        '        indicator.row.classList.add("bg-gray-900", "border-gray-700");\n'
        '        indicator.label.classList.add("text-slate-100");\n'
        '        indicator.status.classList.add("text-rose-300/90");\n'
        '        break;\n'
        '      case "stale":\n'
        '        indicator.row.classList.add("bg-gray-900", "border-gray-700");\n'
        '        indicator.label.classList.add("text-slate-100");\n'
        '        indicator.status.classList.add("text-amber-200/90");\n'
        '        break;\n'
        '      case "unknown":\n'
        '      default:\n'
        '        indicator.row.classList.add("bg-gray-900", "border-gray-700");\n'
        '        indicator.label.classList.add("text-slate-100");\n'
        '        indicator.status.classList.add("text-slate-300/75");\n'
        '        break;\n'
        '    }\n'
        '  }\n\n'
        '  function refreshAgentRows() {\n'
        '    Object.keys(indicators).forEach((key) => {\n'
        '      applyVisual(key, agentReportedState[key] || "unknown");\n'
        '    });\n'
        '  }\n\n'
    )
    text = text[:start] + replacement + text[end:]

text = text.replace(
    '        applyVisual(key, String(status || "unknown"));\n',
    '        agentReportedState[key] = String(status || "unknown");\n'
    '        applyVisual(key, agentReportedState[key]);\n',
)

text = text.replace(
    '      applyVisual(agentName, String(status || "unknown"));\n'
    '      refreshActiveAgentsMetric();\n'
    '      return true;\n',
    '      agentReportedState[agentName] = String(status || "unknown");\n'
    '      applyVisual(agentName, agentReportedState[agentName]);\n'
    '      refreshActiveAgentsMetric();\n'
    '      return true;\n',
)

text = text.replace(
    '    source.onerror = (err) => {\n'
    '      console.warn("agent-status-row.js: OPS SSE error:", err);\n'
    '      Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));\n'
    '      setMetricText(activeAgentsMetricEl, "—");\n'
    '    };\n'
    '  })();\n',
    '    source.onerror = (err) => {\n'
    '      console.warn("agent-status-row.js: OPS SSE error:", err);\n'
    '      Object.keys(agentActivityAt).forEach((key) => delete agentActivityAt[key]);\n'
    '      Object.keys(indicators).forEach((key) => applyVisual(key, agentReportedState[key] || "unknown"));\n'
    '      setMetricText(activeAgentsMetricEl, "—");\n'
    '    };\n\n'
    '    window.setInterval(() => {\n'
    '      refreshActiveAgentsMetric();\n'
    '      refreshAgentRows();\n'
    '    }, 5000);\n'
    '  })();\n',
)

path.write_text(text)
print("patched public/js/agent-status-row.js")
PY
