
#!/bin/bash

set -u

echo "===== PHASE 716 REVERT FAILED SCRIPT + PATCH ACTUAL RENDERER ====="

echo ""

echo "[1] Revert failed script-only commit"

git revert --no-edit 8e39176f

echo ""

echo "[2] Patch actual taskRows renderer by function boundary"

python3 - << 'PY'

from pathlib import Path

import re

path = Path("public/js/phase530_visible_panels_bridge.js")

src = path.read_text()

m = re.search(r"\n  function taskRows\(tasks\) \{", src)

if not m:

    raise SystemExit("Could not find taskRows function")

start = m.start()

next_fn = re.search(r"\n  function\s+\w+\(", src[m.end():])

if not next_fn:

    raise SystemExit("Could not find next function boundary after taskRows")

end = m.end() + next_fn.start()

replacement = r'''

  function taskRows(tasks) {

    if (!tasks || !tasks.length) {

      return `<div style="color:#94a3b8;font-size:.8rem;">No recent tasks yet.</div>`;

    }

    return tasks.map((t) => {

      const title = esc(t.title || t.task_id || t.id || "Untitled task");

      const status = esc(t.status || "unknown");

      const taskId = esc(t.task_id || t.id || "");

      const updated = esc(t.updated_at || "");

      const outcome = esc(t.outcome_preview || "");

      const explanation = esc(t.explanation_preview || "");

      const guidance = t.guidance || {};

      const trace = guidance.communicationResult && guidance.communicationResult.systemTrace

        ? guidance.communicationResult.systemTrace.content

        : null;

      const traceJson = trace ? esc(JSON.stringify(trace, null, 2)) : "";

      return `

        <article data-phase716-contained-task="true" style="display:block;width:100%;min-width:0;max-width:100%;box-sizing:border-box;border:1px solid rgba(148,163,184,.22);border-radius:12px;padding:10px;margin:0 0 10px 0;background:rgba(15,23,42,.72);overflow:hidden;">

          <div style="font-weight:600;color:#e5e7eb;overflow-wrap:anywhere;word-break:break-word;">${title}</div>

          <div style="margin-top:4px;color:#94a3b8;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">status=${status} · id=${taskId}</div>

          ${updated ? `<div style="margin-top:4px;color:#64748b;font-size:11px;overflow-wrap:anywhere;">updated=${updated}</div>` : ""}

          ${outcome ? `<div style="margin-top:8px;color:#d1d5db;font-size:12px;overflow-wrap:anywhere;word-break:break-word;">${outcome}</div>` : ""}

          ${explanation ? `<details style="margin-top:8px;display:block;max-width:100%;overflow:hidden;"><summary style="cursor:pointer;color:#93c5fd;font-size:12px;">details</summary><div style="margin-top:6px;color:#cbd5e1;font-size:12px;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;">${explanation}</div></details>` : ""}

          ${traceJson ? `<details style="margin-top:8px;display:block;max-width:100%;overflow:hidden;"><summary style="cursor:pointer;color:#fbbf24;font-size:12px;">advanced JSON</summary><pre style="display:block;box-sizing:border-box;width:100%;max-width:100%;max-height:220px;overflow:auto;margin-top:6px;padding:8px;border-radius:8px;background:#020617;color:#e5e7eb;font-size:11px;line-height:1.35;white-space:pre-wrap;overflow-wrap:anywhere;word-break:break-word;">${traceJson}</pre></details>` : ""}

        </article>

      `;

    }).join("");

  }

'''

path.write_text(src[:start] + replacement + src[end:])

PY

echo ""

echo "[3] Confirm renderer patch"

grep -n "data-phase716-contained-task\|advanced JSON\|max-height:220px" public/js/phase530_visible_panels_bridge.js

echo ""

echo "[4] Rebuild authoritative containers"

docker compose up -d --build

echo ""

echo "[5] Verify runtime"

docker compose ps

curl -sS -i "http://localhost:3000/" | head -25 || true

curl -sS -i "http://localhost:3000/api/tasks" | head -25 || true

curl -sS -i "http://localhost:3000/api/guidance" | head -25 || true

echo ""

echo "[6] Git status"

git status --short

echo "===== PHASE 716 REVERT FAILED SCRIPT + PATCH ACTUAL RENDERER COMPLETE ====="

