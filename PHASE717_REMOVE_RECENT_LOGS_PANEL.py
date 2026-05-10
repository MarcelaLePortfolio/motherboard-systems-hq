
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old_layout = '''      if (recentCard) {

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

      });'''

new_layout = '''      if (recentCard) {

        recentCard.style.display = "block";

        recentCard.style.minHeight = "0";

        recentCard.style.height = "100%";

      }

      if (recentTasks) {

        recentTasks.style.minHeight = "0";

        recentTasks.style.height = "100%";

        recentTasks.style.overflow = "auto";

        recentTasks.style.display = "block";

      }

      if (recentLogs) {

        recentLogs.style.display = "none";

      }'''

old_logs = '''      if (recentLogs) {

        recentLogs.innerHTML = (tasks && tasks.length)

          ? tasks.map((task) => `

              <div style="border-bottom:1px solid rgba(51,65,85,.55);padding:.5rem 0;color:#cbd5e1;font-size:.8rem;">

                ${esc(task.updated_at || task.created_at || "time unavailable")} · ${esc(task.status || "unknown")} · ${esc(task.title || task.task_id || "Untitled task")}

              </div>

            `).join("")

          : `<div style="color:#94a3b8;font-size:.8rem;">No task history yet.</div>`;

      }'''

new_logs = '''      if (recentLogs) {

        recentLogs.innerHTML = "";

      }'''

if old_layout not in text:

    raise SystemExit("RECENT CARD LAYOUT BLOCK NOT FOUND")

if old_logs not in text:

    raise SystemExit("RECENT LOGS RENDER BLOCK NOT FOUND")

text = text.replace(old_layout, new_layout, 1)

text = text.replace(old_logs, new_logs, 1)

path.write_text(text)

print("Recent Logs panel removed from lifecycle card surface.")

