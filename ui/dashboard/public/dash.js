// ✅ Real-time Agent Status Painter
fetch("./agent-status.json")
  .then((res) => res.json())
  .then((statusMap) => {
    const agentColorMap = {
      online: "green",
      stopped: "gray",
      errored: "red",
      unknown: "goldenrod"
    };

    const agents = {
      matilda: "🧠 Matilda",
      cade: "🛠️ Cade",
      effie: "🖥 Effie"
    };

    document.querySelectorAll(".agent").forEach((el) => {
      const label = el.textContent.trim();
      for (const [key, expectedLabel] of Object.entries(agents)) {
        if (label.includes(expectedLabel)) {
          const span = el.querySelector("span");
          const status = statusMap[key] || "unknown";
          const color = agentColorMap[status] || "goldenrod";
          if (span) {
            span.style.backgroundColor = color;
            el.title = `${expectedLabel} – ${status}`;
          }
        }
      }
    });
  })
  .catch((err) => {
    console.error("❌ Failed to fetch agent status:", err);
  });
