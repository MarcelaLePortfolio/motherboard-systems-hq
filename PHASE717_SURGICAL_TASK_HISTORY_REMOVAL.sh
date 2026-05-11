
#!/bin/bash

set -e

echo "===== PHASE 717 SURGICAL TASK HISTORY REMOVAL ====="

echo ""

echo "[1] Stable checkpoint"

git status --short

git log --oneline --decorate -6

echo ""

echo "[2] Remove ONLY Task History tab + panel"

python3 << 'PY'

from pathlib import Path

path = Path("public/index.html")

text = path.read_text()

tab_block = """              <button id="obs-tab-activity" class="obs-tab" type="button" data-workspace-tab data-target="obs-panel-activity" role="tab" aria-selected="false" aria-controls="obs-panel-activity">

                Task History

"""

panel_block = """              <div id="obs-panel-activity" class="obs-panel" data-workspace-panel role="tabpanel" aria-labelledby="obs-tab-activity" hidden>

                <section id="task-activity-card" class="obs-surface">

                  <div class="h-64 bg-slate-950 border-2 border-blue-500 rounded-xl p-3 shadow-[0_0_0_1px_rgba(59,130,246,0.35),0_20px_50px_rgba(2,6,23,0.8)]" style="background:#020617 !important; border:3px solid #3b82f6 !important; border-radius:1rem !important; box-shadow:0 0 0 2px rgba(59,130,246,0.55),0 22px 60px rgba(2,6,23,0.9) !important;">

                    <canvas id="task-activity-graph" class="w-full h-full"></canvas>

                  </div>

                </section>

              </div>

"""

if tab_block not in text:

    raise SystemExit("Task History tab block not found exactly.")

if panel_block not in text:

    raise SystemExit("Task History panel block not found exactly.")

text = text.replace(tab_block, "", 1)

text = text.replace(panel_block, "", 1)

path.write_text(text)

print("Removed Task History tab + panel only.")

PY

echo ""

echo "[3] Diff verification"

git diff -- public/index.html | sed -n '1,180p'

echo ""

echo "[4] Rebuild dashboard"

docker compose build dashboard >/tmp/phase717_dashboard_build.log 2>&1

docker compose up -d dashboard >/tmp/phase717_dashboard_up.log 2>&1

sleep 3

echo ""

echo "[5] Served validation"

curl -sS http://localhost:3000/ > /tmp/phase717_post_task_history_removal.html

echo "--- Expected remaining surfaces ---"

grep -o 'Telemetry Console\|Recent Tasks\|id="recentTasks"' /tmp/phase717_post_task_history_removal.html | sort | uniq -c || true

echo ""

echo "--- Expected removed surfaces ---"

grep -o 'Task History\|task-activity-card\|task-activity-graph\|obs-panel-activity\|obs-tab-activity' /tmp/phase717_post_task_history_removal.html | sort | uniq -c || true

echo ""

echo "[6] Runtime status"

docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

echo ""

echo "===== SURGICAL TASK HISTORY REMOVAL COMPLETE ====="

