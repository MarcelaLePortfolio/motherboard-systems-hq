
from pathlib import Path

import re

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

# Hide/remove Recent Logs everywhere it is rendered.

text = re.sub(

    r'''    if \(recentLogs\) \{\n      recentLogs\.innerHTML = \(tasks && tasks\.length\)\n        \? tasks\.map\(\(task\) => `[\s\S]*?No task history yet\.</div>`;\n    \}''',

    '''    if (recentLogs) {

      recentLogs.innerHTML = "";

      recentLogs.style.display = "none";

      recentLogs.style.height = "0";

      recentLogs.style.minHeight = "0";

      recentLogs.style.overflow = "hidden";

    }''',

    text,

    count=1

)

marker = "/* phase740 remove recent logs and inner heading */"

if marker not in text:

    patch = r'''

  /* phase740 remove recent logs and inner heading */

  function phase740RemoveRecentLogsAndInnerHeading() {

    const recentLogs = document.getElementById("recentLogs");

    const recentTasks = document.getElementById("recentTasks");

    const recentCard = document.getElementById("recent-tasks-card");

    if (recentLogs) {

      recentLogs.remove();

    }

    if (recentCard) {

      recentCard.querySelectorAll("h2,h3,h4,p").forEach((el) => {

        const txt = (el.textContent || "").trim();

        if (/^recent tasks$/i.test(txt) || /^recent logs$/i.test(txt) || /^task history$/i.test(txt)) {

          el.remove();

        }

      });

    }

    if (recentTasks) {

      recentTasks.style.display = "block";

      recentTasks.style.overflowY = "auto";

      recentTasks.style.overflowX = "hidden";

      recentTasks.style.background = "rgba(2,6,23,.82)";

      recentTasks.style.borderRadius = "14px";

      recentTasks.style.padding = "10px";

      recentTasks.style.boxSizing = "border-box";

    }

  }

  const phase740RunRemoveRecentLogsAndInnerHeading = () => {

    try {

      phase740RemoveRecentLogsAndInnerHeading();

    } catch (error) {

      console.warn("[phase740] remove recent logs/heading failed", error);

    }

  };

  phase740RunRemoveRecentLogsAndInnerHeading();

  setInterval(phase740RunRemoveRecentLogsAndInnerHeading, 1200);

  new MutationObserver(phase740RunRemoveRecentLogsAndInnerHeading).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

path.write_text(text, encoding="utf-8")

