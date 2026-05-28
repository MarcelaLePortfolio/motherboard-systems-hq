
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 operator workspace height balance */"

if marker not in text:

    patch = r'''

  /* phase740 operator workspace height balance */

  function phase740OperatorWorkspaceHeightBalance() {

    const operatorCard = document.getElementById("operator-workspace-card");

    const opPanelChat = document.getElementById("op-panel-chat");

    if (operatorCard) {

      operatorCard.style.display = "flex";

      operatorCard.style.flexDirection = "column";

      operatorCard.style.height = "683px";

      operatorCard.style.minHeight = "683px";

    }

    if (opPanelChat) {

      opPanelChat.style.flex = "1 1 auto";

      opPanelChat.style.display = "flex";

      opPanelChat.style.flexDirection = "column";

      opPanelChat.style.minHeight = "0";

      opPanelChat.style.height = "100%";

    }

    const firstShell = opPanelChat

      ? opPanelChat.querySelector("section, article, div")

      : null;

    if (firstShell) {

      firstShell.style.flex = "1 1 auto";

      firstShell.style.minHeight = "0";

      firstShell.style.height = "100%";

    }

  }

  const phase740RunOperatorWorkspaceHeightBalance = () => {

    try {

      phase740OperatorWorkspaceHeightBalance();

    } catch (error) {

      console.warn("[phase740] operator workspace height balance failed", error);

    }

  };

  phase740RunOperatorWorkspaceHeightBalance();

  setInterval(phase740RunOperatorWorkspaceHeightBalance, 1500);

  new MutationObserver(phase740RunOperatorWorkspaceHeightBalance).observe(document.documentElement, {

    childList: true,

    subtree: true

  });

'''

    end = text.rfind("})();")

    text = text + patch if end == -1 else text[:end] + patch + "\n" + text[end:]

path.write_text(text, encoding="utf-8")

