const chronicleContainer = document.querySelector("#chronicle-feed");
let lastLength = 0;

function colorFor(event) {
  if (!event) return "text-gray-600";
  if (event.includes("executed")) return "text-green-600";
  if (event.includes("learned")) return "text-yellow-600";
  if (event.includes("autoRepaired")) return "text-red-600";
  return "text-gray-600";
}

async function fetchChronicle() {
  try {
    const res = await fetch("/chronicle/list");
    const data = await res.json();
    if (!data.ok) return;

    const logs = data.log || [];

    // If the backend log has been cleared or shrunk, reset the feed.
    if (logs.length < lastLength) {
      chronicleContainer.innerHTML = "";
      lastLength = 0;
    }

    if (logs.length > lastLength) {
      const newEntries = logs.slice(lastLength);

      for (const entry of newEntries) {
        const time = entry.timestamp ? new Date(entry.timestamp).toLocaleTimeString() : "—";
        const color = colorFor(entry.event);

        const item = document.createElement("div");
        item.className = "p-2 mb-2 border border-gray-200 rounded-lg bg-white shadow-sm";
        item.innerHTML = `
          <div class="text-xs text-gray-400">${time}</div>
          <div class="text-sm"><strong class="${color}">${entry.event}</strong> — ${entry.data?.skill || ""}</div>
          <div class="text-xs ${color}">${entry.data?.result || ""}</div>
        `;
        chronicleContainer.appendChild(item);

        chronicleContainer.scrollTo({
          top: chronicleContainer.scrollHeight,
          behavior: "smooth",
        });

        item.animate(
          [{ boxShadow: "0 0 12px rgba(255,200,100,0.6)" }, { boxShadow: "0 0 0 rgba(0,0,0,0)" }],
          { duration: 900, easing: "ease-out" }
        );
      }

      lastLength = logs.length;
    }
  } catch (err) {
    console.error("Chronicle fetch error:", err);
  }
}

// ---- Clear Chronicle (no modal, simple confirm + inline feedback) ----
(function ensureClearButton() {
  if (!chronicleContainer) return;

  if (!document.getElementById("clear-chronicle-btn")) {
    const wrap = document.createElement("div");
    wrap.className = "mb-3 flex justify-end";
    wrap.innerHTML = `
      <button id="clear-chronicle-btn"
        class="px-3 py-1 rounded-lg bg-amber-800/40 border border-amber-700/50 text-amber-100 hover:bg-amber-700/50 transition">
        🧹 Clear Chronicle
      </button>
    `;
    chronicleContainer.parentNode.insertBefore(wrap, chronicleContainer);
  }

  const btn = document.getElementById("clear-chronicle-btn");
  btn.onclick = async () => {
    if (!confirm("Clear all System Chronicle entries?")) return;
    try {
      const res = await fetch("/chronicle/clear", { method: "DELETE" });
      const json = await res.json();
      if (json.ok) {
        chronicleContainer.innerHTML = "";
        lastLength = 0;
        const original = btn.textContent;
        btn.textContent = "✅ Cleared";
        setTimeout(() => (btn.textContent = original), 1200);
      } else {
        const original = btn.textContent;
        btn.textContent = "⚠️ Error";
        setTimeout(() => (btn.textContent = original), 1500);
      }
    } catch {
      const original = btn.textContent;
      btn.textContent = "⚠️ Error";
      setTimeout(() => (btn.textContent = original), 1500);
    }
  };
})();

// poll every 2.5s
setInterval(fetchChronicle, 2500);
fetchChronicle();
