console.log("🚀 dash.js is executing");

fetch("./agent-status.json")
  .then((res) => res.json())
  .then((statusMap) => {
    console.log("📦 Loaded agent-status.json:", statusMap);

    const agents = document.querySelectorAll(".agent");
    agents.forEach((el, i) => {
      const label = el.textContent.trim();
      const span = el.querySelector("span");
      if (span) {
        const key = label.includes("Matilda")
          ? "matilda"
          : label.includes("Cade")
          ? "cade"
          : label.includes("Effie")
          ? "effie"
          : null;
        if (key && statusMap[key]) {
          const color = statusMap[key] === "online" ? "green" : "red";
          span.style.backgroundColor = color;
          el.title = `${label} – ${statusMap[key]}`;
          console.log(`✅ ${label} → ${statusMap[key]} → ${color}`);
        }
      }
    });
  })
  .catch((err) => {
    console.error("❌ Failed to load agent-status.json", err);
  });
