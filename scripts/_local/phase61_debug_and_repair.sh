#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re
import shutil

p = Path("public/dashboard.html")
if not p.exists():
    raise SystemExit("public/dashboard.html not found")

html = p.read_text(encoding="utf-8")
backup = p.with_suffix(".html.bak.phase61_debug")
shutil.copy2(p, backup)

checks = {
    "main_open": "<main" in html,
    "main_close": "</main>" in html,
    "operator_workspace": "Operator Workspace" in html,
    "chat": "Chat" in html,
    "delegation": "Delegation" in html,
    "recent_tasks": "Recent Tasks" in html,
    "task_history_or_activity": ("Task History" in html) or ("Task Activity" in html),
    "task_events": "Task Events" in html,
    "atlas": "Atlas Subsystem Status" in html,
}

missing = [k for k, v in checks.items() if not v]
if missing:
    print("Missing anchors:")
    for m in missing:
        print(f" - {m}")
    raise SystemExit(1)

main_match = re.search(r"(<main\b[^>]*>)(.*?)(</main>)", html, flags=re.S | re.I)
if not main_match:
    raise SystemExit("could not locate <main>...</main> region")

main_open, main_body, main_close = main_match.groups()

def find_pos(body: str, label: str) -> int:
    idx = body.find(label)
    if idx == -1:
        raise SystemExit(f"anchor not found in <main>: {label}")
    return idx

operator_idx = find_pos(main_body, "Operator Workspace")
obs_label = "Observational Workspace" if "Observational Workspace" in main_body else "Telemetry Workspace"
obs_idx = find_pos(main_body, obs_label)
atlas_idx = find_pos(main_body, "Atlas Subsystem Status")

if not (operator_idx < atlas_idx and obs_idx < atlas_idx):
    raise SystemExit("workspace anchors are not positioned before Atlas as expected")

card_starts = [m.start() for m in re.finditer(r'<(?:section|div|article)\b[^>]*>', main_body, flags=re.I)]
card_ends = [m.start() for m in re.finditer(r'</(?:section|div|article)>', main_body, flags=re.I)]

if not card_starts or not card_ends:
    raise SystemExit("could not find enough structural containers to repair")

def find_container_bounds(body: str, anchor: str):
    anchor_pos = body.find(anchor)
    if anchor_pos == -1:
        raise SystemExit(f"anchor not found: {anchor}")

    tag_iter = list(re.finditer(r'</?(section|div|article)\b[^>]*>', body, flags=re.I))
    stack = []
    containing = None

    for m in tag_iter:
        token = m.group(0)
        is_close = token.startswith("</")
        if not is_close:
            stack.append((m.group(1).lower(), m.start(), m.end()))
        else:
            if not stack:
                continue
            open_tag = stack.pop()
            if open_tag[1] <= anchor_pos <= m.end():
                containing = (open_tag[1], m.end())
    if containing is None:
        raise SystemExit(f"could not determine container bounds for: {anchor}")
    return containing

operator_bounds = find_container_bounds(main_body, "Operator Workspace")
obs_bounds = find_container_bounds(main_body, obs_label)
atlas_bounds = find_container_bounds(main_body, "Atlas Subsystem Status")

operator_html = main_body[operator_bounds[0]:operator_bounds[1]]
obs_html = main_body[obs_bounds[0]:obs_bounds[1]]
atlas_html = main_body[atlas_bounds[0]:atlas_bounds[1]]

def ensure_id(block: str, desired_id: str) -> str:
    if f'id="{desired_id}"' in block or f"id='{desired_id}'" in block:
        return block
    return re.sub(
        r'^<([a-zA-Z0-9]+)\b',
        lambda m: f'<{m.group(1)} id="{desired_id}"',
        block,
        count=1,
        flags=re.S
    )

operator_html = ensure_id(operator_html, "operator-workspace-card")
obs_html = ensure_id(obs_html, "observational-workspace-card")
atlas_html = ensure_id(atlas_html, "atlas-subsystem-status-card")

new_shell = f'''
<section id="phase61-workspace-shell">
  <div id="phase61-workspace-grid">
    {operator_html}
    {obs_html}
  </div>
  <section id="phase61-atlas-band">
    {atlas_html}
  </section>
</section>
'''.strip()

start = min(operator_bounds[0], obs_bounds[0], atlas_bounds[0])
end = max(operator_bounds[1], obs_bounds[1], atlas_bounds[1])

new_main_body = main_body[:start] + "\n" + new_shell + "\n" + main_body[end:]

css = """
/* phase61 structural repair */
#phase61-workspace-shell {
  display: block;
  width: 100%;
}

#phase61-workspace-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 16px;
  align-items: start;
  width: 100%;
}

#phase61-atlas-band {
  width: 100%;
  margin-top: 16px;
}

#operator-workspace-card,
#observational-workspace-card,
#atlas-subsystem-status-card {
  min-width: 0;
  width: 100%;
}

@media (max-width: 1100px) {
  #phase61-workspace-grid {
    grid-template-columns: 1fr;
  }
}
""".strip()

if "#phase61-workspace-grid" not in html:
    if "</style>" in html:
        html = html.replace("</style>", "\n" + css + "\n</style>", 1)
    elif "</head>" in html:
        html = html.replace("</head>", f"<style>\n{css}\n</style>\n</head>", 1)
    else:
        raise SystemExit("could not find <style> or </head> to insert CSS")

new_html = html.replace(main_match.group(0), f"{main_open}{new_main_body}{main_close}", 1)
p.write_text(new_html, encoding="utf-8")
print("Phase 61 workspace region repaired.")
PY
