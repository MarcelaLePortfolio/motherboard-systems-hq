
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 recent tasks live layout diagnostic */"

if marker not in text:

    patch = r'''

  /* phase740 recent tasks live layout diagnostic */

  function phase740RecentTasksLiveLayoutDiagnostic() {

    const old = document.getElementById("phase740-recent-layout-diagnostic");

    if (old) old.remove();

    const recentTasks = document.getElementById("recentTasks");

    const rows = [];

    let el = recentTasks;

    let depth = 0;

    while (el && depth < 8) {

      const rect = el.getBoundingClientRect();

      const style = getComputedStyle(el);

      rows.push([

        depth,

        el.tagName.toLowerCase(),

        el.id ? "#" + el.id : "",

        Math.round(rect.width) + "x" + Math.round(rect.height),

        "display=" + style.display,

        "height=" + style.height,

        "gridRows=" + style.gridTemplateRows,

        "gridCols=" + style.gridTemplateColumns,

        "flex=" + style.flex,

        "overflow=" + style.overflow

      ].join(" | "));

      el = el.parentElement;

      depth += 1;

    }

    const box = document.createElement("pre");

    box.id = "phase740-recent-layout-diagnostic";

    box.textContent = "RECENT TASKS LIVE LAYOUT DIAGNOSTIC\n\n" + rows.join("\n");

    box.style.position = "fixed";

    box.style.right = "12px";

    box.style.bottom = "12px";

    box.style.zIndex = "99999";

    box.style.maxWidth = "720px";

    box.style.maxHeight = "360px";

    box.style.overflow = "auto";

    box.style.padding = "12px";

    box.style.border = "1px solid rgba(147,197,253,.65)";

    box.style.borderRadius = "12px";

    box.style.background = "rgba(2,6,23,.96)";

    box.style.color = "#dbeafe";

    box.style.fontSize = "11px";

    box.style.lineHeight = "1.45";

    document.body.appendChild(box);

  }

  setTimeout(phase740RecentTasksLiveLayoutDiagnostic, 1800);

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

path.write_text(text, encoding="utf-8")

