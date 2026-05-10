
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_block = """    if (recentCard) {

      recentCard.style.display = "grid";

      recentCard.style.gridTemplateRows = "1fr 1fr";

      recentCard.style.gap = "1rem";

      recentCard.style.minHeight = "0";

      recentCard.style.height = "100%";

    }

    [recentTasks, recentLogs].forEach((el) => {

      if (!el) return;

      el.style.minHeight = "0";

      el.style.height = "100%";

      el.style.overflow = "auto";

      el.style.display = "block";

    });

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);

    if (recentLogs) {

      recentLogs.innerHTML = (tasks && tasks.length)

        ? tasks.map((task) => `

            <div style="border-bottom:1px solid rgba(51,65,85,.55);padding:.5rem 0;color:#cbd5e1;font-size:.8rem;">

              ${esc(task.updated_at || task.created_at || "time unavailable")} · ${esc(task.status || "unknown")} · ${esc(task.title || task.task_id || "Untitled task")}

            </div>

          `).join("")

        : `<div style="color:#94a3b8;font-size:.8rem;">No task history yet.</div>`;

    }"""

new_block = """    if (recentCard) {

      recentCard.style.display = "block";

      recentCard.style.minHeight = "0";

      recentCard.style.height = "100%";

    }

    if (recentTasks) {

      recentTasks.style.minHeight = "0";

      recentTasks.style.height = "100%";

      recentTasks.style.overflow = "auto";

      recentTasks.style.display = "block";

      recentTasks.innerHTML = taskRows(tasks);

    }

    if (recentLogs) {

      recentLogs.style.display = "none";

      recentLogs.innerHTML = "";

    }"""

if old_block not in text:

    raise SystemExit("TARGET renderRecent BLOCK NOT FOUND")

text = text.replace(old_block, new_block, 1)

path.write_text(text)

print("Recent Logs panel safely removed from Recent Tasks card.")

