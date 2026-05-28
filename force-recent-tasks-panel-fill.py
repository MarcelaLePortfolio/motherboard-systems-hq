
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 force recent tasks panel fill */"

if marker not in text:

    patch = r'''

  /* phase740 force recent tasks panel fill */

  function phase740ForceRecentTasksPanelFill() {

    const recentTasks = document.getElementById("recentTasks");

    const recentLogs = document.getElementById("recentLogs");

    if (!recentTasks) return;

    if (recentLogs) recentLogs.remove();

    let node = recentTasks;

    for (let i = 0; i < 10 && node && node !== document.body; i += 1, node = node.parentElement) {

      node.style.height = "100%";

      node.style.minHeight = "0";

      node.style.maxHeight = "none";

      node.style.flex = "1 1 auto";

      node.style.overflow = node === recentTasks ? "auto" : "hidden";

      if (node !== recentTasks) {

        node.style.display = "flex";

        node.style.flexDirection = "column";

        node.style.gridTemplateRows = "1fr";

        node.style.gap = "0";

      }

    }

    const card = document.getElementById("recent-tasks-card") || recentTasks.closest("section, article, div");

    if (card) {

      card.querySelectorAll("h2,h3,h4").forEach((heading) => {

        if (/recent tasks/i.test(heading.textContent || "")) heading.remove();

      });

    }

    recentTasks.style.display = "block";

    recentTasks.style.height = "100%";

    recentTasks.style.minHeight = "100%";

    recentTasks.style.flex = "1 1 auto";

    recentTasks.style.overflowY = "auto";

    recentTasks.style.background = "rgba(2,6,23,.82)";

    recentTasks.style.borderRadius = "14px";

    recentTasks.style.padding = "10px";

    recentTasks.style.boxSizing = "border-box";

  }

  const phase740RunForceRecentTasksPanelFill = () => {

    try {

      phase740ForceRecentTasksPanelFill();

    } catch (error) {

      console.warn("[phase740] force recent tasks panel fill failed", error);

    }

  };

  phase740RunForceRecentTasksPanelFill();

  setInterval(phase740RunForceRecentTasksPanelFill, 1000);

  new MutationObserver(phase740RunForceRecentTasksPanelFill).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

    path.write_text(text, encoding="utf-8")

