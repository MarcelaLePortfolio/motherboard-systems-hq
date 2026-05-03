#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re
import sys

dashboard = Path("public/dashboard.html")
agent_js = Path("public/js/agent-status-row.js")
bundle_js = Path("public/bundle.js")

html = dashboard.read_text()
js = agent_js.read_text()
bundle = bundle_js.read_text()

original_html = html
original_js = js
original_bundle = bundle

# 1) Ensure dedicated metric value IDs exist in dashboard.html
label_to_id = {
    "Active Agents": "metric-agents",
    "Tasks Running": "metric-tasks",
    "Success Rate": "metric-success",
    "Latency": "metric-latency",
}

def ensure_id_for_label(text: str, label: str, idv: str) -> str:
    if f'id="{idv}"' in text or f"id='{idv}'" in text:
        return text

    pattern = re.compile(
        rf'(<(?P<tag>[^>\s]+)[^>]*class="[^"]*\bmetric-value\b[^"]*"[^>]*>)(?P<val>.*?)(</(?P=tag)>\s*.*?{re.escape(label)})',
        re.IGNORECASE | re.DOTALL,
    )

    def repl(m):
        open_tag = m.group(1)
        val = m.group("val")
        close_and_label = m.group(4)

        if ' id=' in open_tag:
            open_tag2 = re.sub(r'\bid\s*=\s*(".*?"|\'.*?\')', f'id="{idv}"', open_tag, count=1)
        else:
            open_tag2 = open_tag[:-1] + f' id="{idv}">'
        return f"{open_tag2}{val}{close_and_label}"

    new_text, count = pattern.subn(repl, text, count=1)
    if count == 0:
        raise SystemExit(f"Could not bind dedicated value node for label: {label}")
    return new_text

for label, idv in label_to_id.items():
    html = ensure_id_for_label(html, label, idv)

# 2) Bind renderer targets by explicit IDs instead of broad selector scans
old_selector = "document.querySelectorAll('.metric-value')"
new_selector = """[
document.getElementById('metric-agents'),
document.getElementById('metric-tasks'),
document.getElementById('metric-success'),
document.getElementById('metric-latency')
].filter(Boolean)"""

if old_selector in js:
    js = js.replace(old_selector, new_selector)

if old_selector in bundle:
    bundle = bundle.replace(old_selector, new_selector)

# 3) Add a small invariant marker comment near the dedicated IDs for future grepping
if "PHASE62B_DEDICATED_METRIC_VALUE_NODES" not in html:
    html = html.replace(
        'id="metric-agents"',
        'id="metric-agents" data-phase62b-metric-anchor="true"',
        1
    )
    html = html.replace(
        'id="metric-tasks"',
        'id="metric-tasks" data-phase62b-metric-anchor="true"',
        1
    )
    html = html.replace(
        'id="metric-success"',
        'id="metric-success" data-phase62b-metric-anchor="true"',
        1
    )
    html = html.replace(
        'id="metric-latency"',
        'id="metric-latency" data-phase62b-metric-anchor="true"',
        1
    )

if html == original_html:
    print("dashboard.html unchanged")
else:
    dashboard.write_text(html)
    print("patched public/dashboard.html")

if js == original_js:
    print("agent-status-row.js unchanged")
else:
    agent_js.write_text(js)
    print("patched public/js/agent-status-row.js")

if bundle == original_bundle:
    print("bundle.js unchanged")
else:
    bundle_js.write_text(bundle)
    print("patched public/bundle.js")
PY
