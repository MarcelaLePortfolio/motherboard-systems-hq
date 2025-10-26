document.addEventListener("DOMContentLoaded", async () => {
  console.log("✅ dashboard-logs.v3.js running");

  const container = document.getElementById("recentLogs_legacy");
  if (!container) {
    console.warn("⚠️ No #recentLogs found in DOM");
    return;
  }

  async function fetchLogs(endpoint) {
    try {
      const res = await fetch(endpoint);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      console.log(`📥 ${endpoint} →`, data);
      return (data.rows ?? data) || [];
    } catch (err) {
      console.error(`❌ Fetch failed for ${endpoint}:`, err);
      return [];
    }
  }

  let logs = await fetchLogs("/reflections/recent");
  if (logs.length === 0) {
    console.log("⚠️ No reflections found; loading tasks instead");
    logs = await fetchLogs("/tasks/recent");
  }

  container.innerHTML = "";
  if (logs.length === 0) {
    container.textContent = "No logs available.";
    return;
  }

  logs.forEach(log => {
    const div = document.createElement("div");
    div.className = "log-item";
    div.style.cssText =
      "margin-bottom:8px;padding:6px 8px;border-bottom:1px solid #222;font-family:monospace;";
    div.innerHTML = `
      <span style="color:#7fffd4;"><b>${log.type}</b></span> — ${log.result}<br>
      <span style="color:#888;">${log.actor} · ${new Date(log.created_at).toLocaleString()}</span>
    `;
    container.appendChild(div);
  });
});

/* ──────────────────────────────
   Dynamic Diagnostics Loader
   ────────────────────────────── */
document.addEventListener("DOMContentLoaded", async () => {
  const container = document.getElementById("diagnostics-grid");
  if (!container) return;

  const endpoints = [
    { id: "cognitiveCohesion", url: "/diagnostics/cognitive-cohesion" },
    { id: "insightVisualizer", url: "/diagnostics/insight-visualizer" },
    { id: "systemHealth", url: "/diagnostics/system-health" },
    { id: "persistentInsight", url: "/diagnostics/persistent-insight" },
    { id: "autonomicAdaptation", url: "/diagnostics/autonomic-adaptation" },
    { id: "introspectiveSim", url: "/diagnostics/introspective-sim" },
    { id: "dashboardSelfVerify", url: "/diagnostics/dashboard-selfverify" },
    { id: "systemChronicle", url: "/diagnostics/system-chronicle" },
  ];

  for (const { id, url } of endpoints) {
    const card = document.createElement("div");
    card.className = "diagnostic-card";
    card.innerHTML = `<h3>${id}</h3><pre>Loading...</pre>`;
    container.appendChild(card);

    try {
      const res = await fetch(url);
      const data = await res.json();
      card.querySelector("pre").textContent = JSON.stringify(data, null, 2);
    } catch {
      card.querySelector("pre").textContent = "⚠️ Offline or unavailable";
    }
  }
});
