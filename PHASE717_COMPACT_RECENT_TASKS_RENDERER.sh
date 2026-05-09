
#!/bin/bash

set -euo pipefail

cd "/Users/marcela-dev/Projects/Motherboard_Systems_HQ"

python3 << 'PY'

from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_details = '${explanation ? `<details style="margin-top:8px;display:block;max-width:100%;overflow:hidden;"><summary style="cursor:pointer;color:#93c5fd;font-size:12px;">details</summary><div style="margin-top:6px;color:#cbd5e1;font-size:12px;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;">${explanation}</div></details>` : ""}'

new_details = '${explanation ? `<div data-phase717-compact-details="true" style="margin-top:8px;color:#93c5fd;font-size:12px;overflow-wrap:anywhere;">Details available in the read-only audit/evidence surfaces.</div>` : ""}'

old_advanced = '${traceJson ? `<details style="margin-top:8px;display:block;max-width:100%;overflow:hidden;"><summary style="cursor:pointer;color:#fbbf24;font-size:12px;">advanced JSON</summary><pre style="display:block;box-sizing:border-box;width:100%;max-width:100%;max-height:220px;overflow:auto;margin-top:6px;padding:8px;border-radius:8px;background:#020617;color:#e5e7eb;font-size:11px;line-height:1.35;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;">${traceJson}</pre></details>` : ""}'

new_advanced = '${traceJson ? `<div data-phase717-compact-advanced-trace="true" style="margin-top:6px;color:#fbbf24;font-size:12px;overflow-wrap:anywhere;">Advanced trace captured; use /execution-evidence.html for read-only forensic review.</div>` : ""}'

if old_details not in text:

    raise SystemExit("Expected details block not found; refusing speculative patch.")

if old_advanced not in text:

    raise SystemExit("Expected advanced JSON block not found; refusing speculative patch.")

text = text.replace(old_details, new_details)

text = text.replace(old_advanced, new_advanced)

path.write_text(text)

PY

cat > PHASE717_RECENT_TASKS_DENSITY_REDUCED.md << 'NOTE'

# Phase 717 Recent Tasks Density Reduced

Changed only the confirmed renderer file:

- public/js/phase530_visible_panels_bridge.js

What changed:

- Removed inline expandable task explanation details from Recent Tasks cards.

- Removed inline expandable advanced JSON trace blocks from Recent Tasks cards.

- Replaced both with compact audit/evidence pointers.

- Preserved lifecycle badge.

- Preserved Requeue control.

- Preserved Retry differently control.

- Preserved renderer-scoped containment.

- Preserved /execution-evidence.html as read-only forensic/audit surface.

Boundary preserved:

- no broad CSS changes

- no execution coupling

- no chat coupling

- no retry contract changes

- no database schema changes

NOTE

docker compose restart dashboard

sleep 3

curl -fsS http://localhost:3000 >/tmp/phase717_compact_recent_tasks.html

grep -RInE "data-phase717-compact-details|data-phase717-compact-advanced-trace" public/js/phase530_visible_panels_bridge.js

if grep -RIn "advanced JSON" public/js/phase530_visible_panels_bridge.js; then

  echo "Unexpected inline advanced JSON label remains."

  exit 1

fi

docker compose ps

git status --short

git add public/js/phase530_visible_panels_bridge.js PHASE717_COMPACT_RECENT_TASKS_RENDERER.sh PHASE717_RECENT_TASKS_DENSITY_REDUCED.md

git commit -m "Phase 717: compact recent tasks evidence density"

git push origin dev

