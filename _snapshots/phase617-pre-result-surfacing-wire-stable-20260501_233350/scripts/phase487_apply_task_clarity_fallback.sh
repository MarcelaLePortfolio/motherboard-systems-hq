#!/bin/bash

set -euo pipefail

echo "────────────────────────────────"
echo "PHASE 487 — APPLY TASK CLARITY FALLBACK"
echo "────────────────────────────────"

if [[ ! -d .git ]]; then
  echo "ERROR: Run this from the repo root."
  exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
  echo "ERROR: Working tree is not clean."
  git status --short
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

targets = [Path("public/dashboard.html"), Path("public/index.html")]

block = r'''<script id="phase487-task-clarity-fallback">
(function () {
  function formatTimestamp(value) {
    if (!value) return "time unavailable";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleString();
  }

  function normalizeStatus(value) {
    return String(value || "unknown").replace(/_/g, " ");
  }

  function taskSummary(task) {
    const title = String(task.title || "Untitled task");
    const status = normalizeStatus(task.status);
    const updated = formatTimestamp(task.updated_at || task.created_at);
    return { title, status, updated };
  }

  function renderTasks(tasks) {
    const mount = document.getElementById("tasks-widget");
    if (!mount) return;

    mount.innerHTML = "";

    const wrapper = document.createElement("div");
    wrapper.style.display = "grid";
    wrapper.style.gap = "10px";

    const items = Array.isArray(tasks) ? tasks.slice(0, 8) : [];

    if (items.length === 0) {
      const empty = document.createElement("div");
      empty.className = "rounded-xl border border-gray-700 bg-gray-900/60 p-4 text-sm text-gray-400";
      empty.textContent = "No recent tasks available.";
      wrapper.appendChild(empty);
      mount.appendChild(wrapper);
      return;
    }

    items.forEach((task) => {
      const summary = taskSummary(task);

      const card = document.createElement("div");
      card.className = "rounded-xl border border-gray-700 bg-gray-900/60 p-4";

      const title = document.createElement("div");
      title.className = "text-sm font-semibold text-gray-100";
      title.textContent = summary.title;

      const meta = document.createElement("div");
      meta.className = "mt-2 text-xs text-gray-400 leading-5";
      meta.innerHTML =
        "Status: " + summary.status + "<br>" +
        "Updated: " + summary.updated;

      card.appendChild(title);
      card.appendChild(meta);
      wrapper.appendChild(card);
    });

    mount.appendChild(wrapper);
  }

  async function refreshTasks() {
    try {
      const res = await fetch("/api/tasks", { cache: "no-store" });
      if (!res.ok) throw new Error("tasks fetch failed");
      const data = await res.json();
      renderTasks(Array.isArray(data.tasks) ? data.tasks : []);
    } catch (_) {
      renderTasks([]);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", refreshTasks, { once: true });
  } else {
    refreshTasks();
  }
})();
</script>
'''

for path in targets:
    text = path.read_text()
    start = text.find('<script id="phase487-task-clarity-fallback">')
    if start != -1:
        end = text.find('</script>', start)
        if end == -1:
            raise SystemExit(f"ERROR: malformed existing task clarity block in {path}")
        end += len('</script>')
        text = text[:start] + block + text[end:]
    else:
        anchor = '</body>'
        idx = text.rfind(anchor)
        if idx == -1:
            raise SystemExit(f"ERROR: could not find </body> in {path}")
        text = text[:idx] + block + "\n" + text[idx:]
    path.write_text(text)
    print(f"PATCHED: {path}")
PY

git add public/dashboard.html public/index.html
git commit -m "PHASE 487: add UI-only task clarity fallback using api tasks"
git push

docker compose up -d --build

curl -s http://localhost:8080 | rg -n "phase487-task-clarity-fallback|tasks-widget" || true
curl -s http://localhost:8080/api/tasks
