// <0001faf7> Phase 9.2 — Atlas lifecycle visualization banner
// Injects a live banner + status indicator for Atlas events

const atlasBanner = document.createElement("div");
atlasBanner.id = "atlas-banner";
atlasBanner.style.position = "fixed";
atlasBanner.style.top = "0";
atlasBanner.style.left = "0";
atlasBanner.style.width = "100%";
atlasBanner.style.padding = "10px 0";
atlasBanner.style.textAlign = "center";
atlasBanner.style.fontFamily = "var(--font-family, 'IBM Plex Sans')";
atlasBanner.style.fontSize = "16px";
atlasBanner.style.background = "linear-gradient(90deg, #6a11cb 0%, #2575fc 100%)";
atlasBanner.style.color = "white";
atlasBanner.style.zIndex = "1000";
atlasBanner.style.display = "none";
atlasBanner.innerText = "🌍 Atlas: Initializing...";
document.body.prepend(atlasBanner);

const evtSource = new EventSource("http://localhost:3201/events/ops");
evtSource.onmessage = (e) => {
  try {
    const data = JSON.parse(e.data);
    if (data.agent === "Atlas" && data.status) {
      atlasBanner.style.display = "block";
      atlasBanner.innerText = `🌍 Atlas: ${data.status}`;
      if (["online", "ready", "complete"].includes(data.status.toLowerCase())) {
        atlasBanner.style.background = "linear-gradient(90deg, #4CAF50, #81C784)";
      } else if (["error", "failed"].includes(data.status.toLowerCase())) {
        atlasBanner.style.background = "linear-gradient(90deg, #F44336, #E57373)";
      } else {
        atlasBanner.style.background = "linear-gradient(90deg, #6a11cb, #2575fc)";
      }
    }
  } catch (err) {
    console.warn("⚠️ Atlas status parse error:", e.data);
  }
};
