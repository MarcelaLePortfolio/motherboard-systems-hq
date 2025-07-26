// 🛠️ DEBUG AGENT STATUS FETCH + DOM MATCH
fetch("./agent-status.json")
  .then((res) => res.json())
  .then((statusMap) => {
    console.log("📦 Loaded agent-status.json:", statusMap);

    const agentColorMap = {
      online: "green",
      stopped: "gray",
      errored: "red",
      offline: "gray",
      unknown: "goldenrod"
    };

    const agents = {
      matilda: "🧠 Matilda",
      cade: "🛠️ Cade",
      effie: "🖥 Effie"
    };

    document.querySelectorAll(".agent").forEach((el, i) => {
      const label = el.textContent.trim();
      console.log(`🔍 Agent[${i}]:`, label);

      for (const [key, expectedLabel] of Object.entries(agents)) {
        if (label.includes(expectedLabel)) {
          const span = el.querySelector("span");
          const status = statusMap[key] || "unknown";
          const color = agentColorMap[status] || "goldenrod";
          if (span) {
            span.style.backgroundColor = color;
            el.title = `${expectedLabel} – ${status}`;
            console.log(`✅ ${expectedLabel} → ${status} → ${color}`);
          } else {
            console.warn(`⚠️ No span found for ${expectedLabel}`);
          }
        }
      }
    });
  })
  .catch((err) => {
    console.error("❌ Failed to fetch or paint agent statuses:", err);
  });
