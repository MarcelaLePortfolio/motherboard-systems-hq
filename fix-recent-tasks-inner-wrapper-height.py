
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 recent tasks inner wrapper height fix */"

if marker not in text:

    patch = r'''

  /* phase740 recent tasks inner wrapper height fix */

  function phase740RecentTasksInnerWrapperHeightFix() {

    const diagnostic = document.getElementById("phase740-recent-layout-diagnostic");

    if (diagnostic) diagnostic.remove();

    const recentTasks = document.getElementById("recentTasks");

    const recentLogs = document.getElementById("recentLogs");

    if (recentLogs) {

      recentLogs.style.display = "none";

      recentLogs.style.height = "0";

      recentLogs.style.minHeight = "0";

      recentLogs.style.overflow = "hidden";

    }

    if (recentTasks && recentTasks.parentElement) {

      const wrapper = recentTasks.parentElement;

      wrapper.style.flex = "1 1 auto";

      wrapper.style.height = "100%";

      wrapper.style.minHeight = "0";

      wrapper.style.overflow = "hidden";

      wrapper.style.display = "flex";

      wrapper.style.flexDirection = "column";

    }

    if (recentTasks) {

      recentTasks.style.flex = "1 1 auto";

      recentTasks.style.height = "100%";

      recentTasks.style.minHeight = "0";

      recentTasks.style.overflowY = "auto";

      recentTasks.style.overflowX = "hidden";

      recentTasks.style.display = "block";

    }

  }

  const phase740RunRecentTasksInnerWrapperHeightFix = () => {

    try {

      phase740RecentTasksInnerWrapperHeightFix();

    } catch (error) {

      console.warn("[phase740] recent tasks inner wrapper height fix failed", error);

    }

  };

  phase740RunRecentTasksInnerWrapperHeightFix();

  setInterval(phase740RunRecentTasksInnerWrapperHeightFix, 1200);

  new MutationObserver(phase740RunRecentTasksInnerWrapperHeightFix).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

path.write_text(text, encoding="utf-8")

