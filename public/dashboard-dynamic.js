// <0001fa92> Dynamic Panel Auto-Refresher
console.log("⚙️ dashboard-dynamic.js loaded");

export async function autoRefreshPanel(id, endpoint, interval = 5000) {
  const el = document.getElementById(id);
  if (!el) return console.warn(`⚠️ Missing container: ${id}`);

  async function update() {
    try {
      const res = await fetch(endpoint);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      el.innerHTML = `<pre style="margin:0;font-family:monospace;">${JSON.stringify(data, null, 2)}</pre>`;
    } catch (err) {
      el.innerHTML = `<div style="color:#f66;font-family:monospace;">⚠️ ${endpoint} unavailable</div>`;
      console.error(`[DynamicPanel:${id}]`, err);
    }
  }

  await update();
  setInterval(update, interval);
}
