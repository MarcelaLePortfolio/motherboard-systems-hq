// <0001fafb> Phase 6.7 — Audio/Visual Alerts on Task Completion
export function setupTaskAlerts() {
  const alertSound = new Audio("/assets/notify.mp3");

  function playAlert() {
    alertSound.currentTime = 0;
    alertSound.play().catch(() => console.warn("🔇 Audio playback blocked by browser policy"));
  }

  function flashScreen() {
    const flash = document.createElement("div");
    flash.style.position = "fixed";
    flash.style.top = 0;
    flash.style.left = 0;
    flash.style.width = "100%";
    flash.style.height = "100%";
    flash.style.background = "rgba(255,255,255,0.5)";
    flash.style.zIndex = 9999;
    flash.style.transition = "opacity 0.4s ease";
    document.body.appendChild(flash);
    setTimeout(() => (flash.style.opacity = "0"), 200);
    setTimeout(() => flash.remove(), 600);
  }

  // Event listener for OPS stream messages
  const evtSource = new EventSource("http://localhost:3201/events/ops");
  evtSource.onmessage = (e) => {
    try {
      const data = JSON.parse(e.data);
      if (data?.status === "completed") {
        playAlert();
        flashScreen();
        console.log(`🔔 Task completed: ${data.event_type || data.type}`);
      }
    } catch (err) {
      console.error("❌ OPS Alert Stream Error:", err);
    }
  };

  evtSource.onerror = () => console.warn("⚠️ OPS Stream disconnected — reconnecting...");
}
window.addEventListener("DOMContentLoaded", setupTaskAlerts);
