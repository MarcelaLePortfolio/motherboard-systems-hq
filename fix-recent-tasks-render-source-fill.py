
from pathlib import Path

import re

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

text = text.replace(

'''      recentCard.style.display = "grid";

      recentCard.style.gridTemplateRows = "1fr 1fr";

      recentCard.style.gap = "1rem";

      recentCard.style.minHeight = "0";

      recentCard.style.height = "100%";''',

'''      recentCard.style.display = "flex";

      recentCard.style.flexDirection = "column";

      recentCard.style.gap = "0";

      recentCard.style.minHeight = "0";

      recentCard.style.height = "100%";

      recentCard.style.overflow = "hidden";'''

)

text = text.replace(

'''    [recentTasks, recentLogs].forEach((el) => {

      if (!el) return;

      el.style.minHeight = "0";

      el.style.height = "100%";

      el.style.overflow = "auto";

      el.style.display = "block";

    });''',

'''    if (recentTasks) {

      recentTasks.style.minHeight = "0";

      recentTasks.style.height = "100%";

      recentTasks.style.flex = "1 1 auto";

      recentTasks.style.overflow = "auto";

      recentTasks.style.display = "block";

    }

    if (recentLogs) {

      recentLogs.style.display = "none";

      recentLogs.style.height = "0";

      recentLogs.style.minHeight = "0";

      recentLogs.style.overflow = "hidden";

    }'''

)

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

path.write_text(text, encoding="utf-8")

