
from pathlib import Path

import re

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

text = re.sub(

    r'\n\s*/\* phase740 operator workspace height balance \*/[\s\S]*?new MutationObserver\(phase740RunOperatorWorkspaceHeightBalance\)\.observe\(document\.documentElement,\s*\{\s*childList:\s*true,\s*subtree:\s*true\s*\}\);\n',

    "\n",

    text,

    count=1,

)

marker = "/* phase740 operator workspace grid-row stretch */"

if marker not in text:

    patch = r'''

  /* phase740 operator workspace grid-row stretch */

  function phase740OperatorWorkspaceGridRowStretch() {

    const operatorColumn = document.getElementById("phase61-telemetry-column")?.previousElementSibling;

    const operatorCard = document.getElementById("operator-workspace-card");

    const telemetryCard = document.getElementById("observational-workspace-card");

    if (operatorColumn) {

      operatorColumn.style.display = "flex";

      operatorColumn.style.flexDirection = "column";

      operatorColumn.style.height = "100%";

      operatorColumn.style.minHeight = "0";

      operatorColumn.style.alignSelf = "stretch";

    }

    if (operatorCard) {

      operatorCard.style.flex = "1 1 auto";

      operatorCard.style.height = "100%";

      operatorCard.style.minHeight = "0";

      operatorCard.style.display = "flex";

      operatorCard.style.flexDirection = "column";

      operatorCard.style.alignSelf = "stretch";

    }

    if (telemetryCard && operatorCard) {

      const telemetryHeight = telemetryCard.getBoundingClientRect().height;

      const operatorHeight = operatorCard.getBoundingClientRect().height;

      if (telemetryHeight > 0 && Math.abs(telemetryHeight - operatorHeight) > 2) {

        operatorCard.style.minHeight = Math.round(telemetryHeight) + "px";

      }

    }

  }

  const phase740RunOperatorWorkspaceGridRowStretch = () => {

    try {

      phase740OperatorWorkspaceGridRowStretch();

    } catch (error) {

      console.warn("[phase740] operator workspace grid-row stretch failed", error);

    }

  };

  phase740RunOperatorWorkspaceGridRowStretch();

  setInterval(phase740RunOperatorWorkspaceGridRowStretch, 1500);

  new MutationObserver(phase740RunOperatorWorkspaceGridRowStretch).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

path.write_text(text, encoding="utf-8")

