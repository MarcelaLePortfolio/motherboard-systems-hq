
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 authoritative recent tasks fill */"

if marker not in text:

    patch = r'''

  /* phase740 authoritative recent tasks fill */

  function phase740AuthoritativeRecentTasksFill() {

    const recentTasks = document.getElementById("recentTasks");

    const recentLogs = document.getElementById("recentLogs");

    const recentCard = document.getElementById("recent-tasks-card");

    if (recentLogs) {

      recentLogs.style.display = "none";

      recentLogs.style.height = "0";

      recentLogs.style.minHeight = "0";

      recentLogs.style.overflow = "hidden";

    }

    if (recentCard) {

      recentCard.style.display = "flex";

      recentCard.style.flexDirection = "column";

      recentCard.style.height = "100%";

      recentCard.style.minHeight = "0";

      recentCard.style.overflow = "hidden";

    }

    if (recentTasks) {

      recentTasks.style.display = "block";

      recentTasks.style.flex = "1 1 100%";

      recentTasks.style.height = "100%";

      recentTasks.style.minHeight = "100%";

      recentTasks.style.maxHeight = "100%";

      recentTasks.style.overflowY = "auto";

      recentTasks.style.overflowX = "hidden";

      recentTasks.style.boxSizing = "border-box";

      recentTasks.style.background = "rgba(2,6,23,.72)";

      recentTasks.style.borderRadius = "14px";

      recentTasks.style.padding = "10px";

    }

  }

  const phase740RunAuthoritativeRecentTasksFill = () => {

    try {

      phase740AuthoritativeRecentTasksFill();

    } catch (error) {

      console.warn("[phase740] authoritative recent tasks fill failed", error);

    }

  };

  phase740RunAuthoritativeRecentTasksFill();

  setInterval(phase740RunAuthoritativeRecentTasksFill, 1500);

  new MutationObserver(phase740RunAuthoritativeRecentTasksFill).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

    path.write_text(text, encoding="utf-8")

