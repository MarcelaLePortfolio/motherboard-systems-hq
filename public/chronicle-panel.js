async function fetchChronicle() {
  try {
    const res = await fetch("/chronicle/list");
    const data = await res.json();
    if (!data.ok) return;

    const container = document.getElementById("chronicle-feed");
    container.innerHTML = "";

    for (const entry of data.log.reverse()) {
      const time = entry.timestamp ? new Date(entry.timestamp).toLocaleTimeString() : "—";
      const color =
        entry.event.includes("executed") ? "text-green-600" :
        entry.event.includes("learned") ? "text-yellow-600" :
        entry.event.includes("autoRepaired") ? "text-red-600" :
        "text-gray-600";

      const item = document.createElement("div");
      item.className = "p-2 border-b border-gray-200";
      item.innerHTML = `
        <div class="text-xs text-gray-400">${time}</div>
        <div class="text-sm"><strong class="${color}">${entry.event}</strong> — ${entry.data.skill || ""}</div>
        <div class="text-xs ${color}">${entry.data.result || ""}</div>
      `;
      container.appendChild(item);
    }
  } catch (err) {
    console.error("Chronicle fetch error:", err);
  }
}

setInterval(fetchChronicle, 3000);
fetchChronicle();
