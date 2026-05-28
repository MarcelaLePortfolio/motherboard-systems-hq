
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 recent tasks full-card fill */"

if marker not in text:

    patch = r'''

  /* phase740 recent tasks full-card fill */

  function phase740RecentTasksFullCardFill() {

    const recentTasks = document.getElementById("recentTasks");

    if (!recentTasks) return;

    const wrappers = [];

    let node = recentTasks;

    for (let i = 0; i < 6 && node; i += 1) {

      wrappers.push(node);

      node = node.parentElement;

    }

    wrappers.forEach((el) => {

      if (!el || el === document.body || el === document.documentElement) return;

      el.style.minHeight = "0";

      el.style.height = "100%";

      el.style.flex = "1 1 auto";

      el.style.display = el === recentTasks ? "block" : "flex";

      el.style.flexDirection = "column";

      el.style.overflow = el === recentTasks ? "auto" : "hidden";

    });

    recentTasks.style.width = "100%";

    recentTasks.style.boxSizing = "border-box";

    recentTasks.style.background = "rgba(2,6,23,.72)";

    recentTasks.style.borderRadius = "14px";

    recentTasks.style.padding = "10px";

  }

  const phase740RunRecentTasksFullCardFill = () => {

    try {

      phase740RecentTasksFullCardFill();

    } catch (error) {

      console.warn("[phase740] recent tasks full-card fill failed", error);

    }

  };

  phase740RunRecentTasksFullCardFill();

  setInterval(phase740RunRecentTasksFullCardFill, 1500);

  new MutationObserver(phase740RunRecentTasksFullCardFill).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    if end == -1:

        text = text + patch

    else:

        text = text[:end] + patch + "\n" + text[end:]

    path.write_text(text, encoding="utf-8")

