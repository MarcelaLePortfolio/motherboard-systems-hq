
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

old = '''      if (recentLogs) {

        recentLogs.style.display = "none";

      }

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);

    if (recentLogs) recentLogs.innerHTML = "";'''

new = '''      if (recentLogs) {

        recentLogs.style.display = "none";

        recentLogs.style.height = "0";

        recentLogs.style.minHeight = "0";

        recentLogs.style.overflow = "hidden";

        recentLogs.innerHTML = "";

        let node = recentLogs.previousElementSibling;

        while (node) {

          const label = String(node.textContent || "").trim().toUpperCase();

          if (label === "RECENT LOGS") {

            node.style.display = "none";

            node.style.height = "0";

            node.style.margin = "0";

            node.style.padding = "0";

            break;

          }

          node = node.previousElementSibling;

        }

      }

    if (recentTasks) recentTasks.innerHTML = taskRows(tasks);'''

if old not in text:

    raise SystemExit("CURRENT RECENT LOGS HIDE BLOCK NOT FOUND")

text = text.replace(old, new, 1)

path.write_text(text)

print("Recent Logs shell hidden and Recent Tasks retained as full lifecycle card.")

