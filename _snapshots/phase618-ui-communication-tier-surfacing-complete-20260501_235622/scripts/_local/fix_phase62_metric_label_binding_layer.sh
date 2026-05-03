#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

dashboard = Path("public/dashboard.html")
agent_js = Path("public/js/agent-status-row.js")
bundle_js = Path("public/bundle.js")

html = dashboard.read_text()
js = agent_js.read_text()
bundle = bundle_js.read_text()

labels_to_ids = {
    "Active Agents": "metric-agents",
    "Tasks Running": "metric-tasks",
    "Success Rate": "metric-success",
    "Latency (ms)": "metric-latency",
}

# Fix metric value IDs by matching the label line and rewriting the nearest preceding metric-value <p>
for label, metric_id in labels_to_ids.items():
    label_pat = re.compile(
        rf'(<p[^>]*class="[^"]*\bphase62-metric-label\b[^"]*"[^>]*>\s*{re.escape(label)}\s*</p>)',
        re.IGNORECASE
    )
    m = label_pat.search(html)
    if not m:
        raise SystemExit(f"label not found in dashboard.html: {label}")

    prefix = html[:m.start()]
    suffix = html[m.start():]

    value_pat = re.compile(
        r'(<p[^>]*class="[^"]*\bphase62-metric-value\b[^"]*"[^>]*)(\s+id="[^"]*")?([^>]*>)',
        re.IGNORECASE
    )
    matches = list(value_pat.finditer(prefix))
    if not matches:
        raise SystemExit(f"no metric value node found before label: {label}")

    vm = matches[-1]
    open_tag = vm.group(1)
    tail = vm.group(3)

    rebuilt = open_tag
    rebuilt = re.sub(r'\s+id="[^"]*"', '', rebuilt)
    rebuilt = re.sub(r'\s+data-phase62b-metric-anchor="true"', '', rebuilt)
    rebuilt = rebuilt + f' id="{metric_id}" data-phase62b-metric-anchor="true"' + tail

    prefix = prefix[:vm.start()] + rebuilt + prefix[vm.end():]
    html = prefix + suffix

dashboard.write_text(html)

def replace_locator(text: str, fn_name: str, metric_id: str) -> str:
    exact = f"const {fn_name} = () => document.getElementById('{metric_id}');"
    if exact in text:
        return text

    pattern = re.compile(
        rf'const\s+{re.escape(fn_name)}\s*=\s*\(\)\s*=>\s*\{{.*?\n\s*\}};',
        re.DOTALL
    )
    new_text, count = pattern.subn(exact, text, count=1)
    if count:
        return new_text

    raise SystemExit(f"locator function not found: {fn_name}")

for fn_name, metric_id in (
    ("findTasksRunningValueNode", "metric-tasks"),
    ("findSuccessRateValueNode", "metric-success"),
    ("findLatencyValueNode", "metric-latency"),
):
    js = replace_locator(js, fn_name, metric_id)
    bundle = replace_locator(bundle, fn_name, metric_id)

agent_js.write_text(js)
bundle_js.write_text(bundle)

print("patched public/dashboard.html")
print("patched public/js/agent-status-row.js")
print("patched public/bundle.js")
PY
