
from pathlib import Path

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text(encoding="utf-8")

marker = "/* phase740 telemetry console polish */"

if marker not in text:

    patch = r'''

  /* phase740 telemetry console polish */

  function phase740TelemetryConsolePolish() {

    const recentTasks = document.getElementById("recentTasks");

    const recentLogs = document.getElementById("recentLogs");

    const recentCard = document.getElementById("recent-tasks-card") || (recentTasks ? recentTasks.closest("section, article, div") : null);

    document.querySelectorAll("button, [role='tab'], .tab, h2, h3, h4, .uppercase, .tracking-wide").forEach((el) => {

      const label = String(el.textContent || "").trim().toLowerCase();

      if (label === "execution inspector" || label === "recent logs" || label === "recent tasks") {

        el.style.display = "none";

        el.setAttribute("aria-hidden", "true");

      }

    });

    if (recentLogs) {

      recentLogs.style.display = "none";

      recentLogs.setAttribute("aria-hidden", "true");

    }

    if (recentCard) {

      recentCard.style.display = "flex";

      recentCard.style.flexDirection = "column";

      recentCard.style.minHeight = "0";

      recentCard.style.height = "100%";

      recentCard.style.overflow = "hidden";

    }

    if (recentTasks) {

      recentTasks.style.display = "block";

      recentTasks.style.flex = "1 1 auto";

      recentTasks.style.height = "100%";

      recentTasks.style.minHeight = "0";

      recentTasks.style.overflowY = "auto";

      recentTasks.style.overflowX = "hidden";

    }

  }

  const phase740RunTelemetryConsolePolish = () => {

    try {

      phase740TelemetryConsolePolish();

    } catch (error) {

      console.warn("[phase740] telemetry console polish failed", error);

    }

  };

  phase740RunTelemetryConsolePolish();

  setInterval(phase740RunTelemetryConsolePolish, 1500);

  new MutationObserver(phase740RunTelemetryConsolePolish).observe(document.documentElement, {

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

