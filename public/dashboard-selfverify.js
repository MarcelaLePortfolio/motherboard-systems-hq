(function(){
  function ensureSelfVerifyPanel(){
    const existing = document.getElementById("adaptationVerify");
    if (existing) return existing;

    const adaptationPanel = document.getElementById("adaptationPanel");
    let container;
    if (adaptationPanel && adaptationPanel.parentElement) {
      // Insert a Self-Verification panel right after Autonomic Adaptation panel
      const wrapper = document.createElement("div");
      wrapper.innerHTML = `
        <h3 style="margin-top:0.5rem;">Self-Verification</h3>
        <div id="adaptationVerify" style="height:90px;overflow-y:auto;border:1px solid #ccc;padding:0.5rem;background:#f0fff7;font-size:0.9rem">
          Checking...
        </div>
      `;
      adaptationPanel.parentElement.insertBefore(wrapper, adaptationPanel.nextSibling);
      container = wrapper.querySelector("#adaptationVerify");
    } else {
      // Fallback: add to end of body if layout not found
      const wrapper = document.createElement("div");
      wrapper.innerHTML = `
        <h3>Self-Verification</h3>
        <div id="adaptationVerify" style="height:90px;overflow-y:auto;border:1px solid #ccc;padding:0.5rem;background:#f0fff7;font-size:0.9rem">
          Checking...
        </div>
      `;
      document.body.appendChild(wrapper);
      container = wrapper.querySelector("#adaptationVerify");
    }
    return container;
  }

  function classifyStatus(success, risk){
    if (success >= 98 && risk < 3) return { label: "Stable", color: "#00c853" };
    if (success >= 95 && risk < 5) return { label: "Monitoring", color: "#ffab00" };
    return { label: "Risk", color: "#d50000" };
  }

  async function refreshAdaptationVerify(){
    try {
      const container = ensureSelfVerifyPanel();
      if (!container) return;

      // Fetch current audit interval
      const vRes = await fetch("/adaptation/verify");
      const verify = await vRes.json();

      // Fetch latest success/risk for color coding
      const tRes = await fetch("/visual/trends");
      const trends = await tRes.json();
      const latest = (trends?.trends?.data || []).slice(-1)[0] || null;

      let status = { label: "Unknown", color: "#555" };
      if (latest && typeof latest.success === "number" && typeof latest.risk === "number") {
        status = classifyStatus(latest.success, latest.risk);
      }

      if (!verify.ok) {
        container.style.background = "#fff8e1";
        container.innerHTML = `
          <div><strong style="color:#d50000">Self-Audit Interval:</strong> unavailable</div>
          <div><em>Reason:</em> ${verify.error || "Unknown"}</div>
          <div><span style="color:${status.color}">Status:</span> ${status.label}</div>
        `;
        return;
      }

      const a = verify.audit;
      const next = a?.nextRun ? new Date(a.nextRun).toLocaleTimeString() : "n/a";
      container.style.background = "#f0fff7";
      container.innerHTML = `
        <div><strong style="color:${status.color}">Status:</strong> ${status.label}</div>
        <div>Self-Audit Interval: <strong>${a.intervalHours}h</strong> ${a.enabled ? "🟢 enabled" : "⚪ disabled"}</div>
        <div>Next Run: <strong>${next}</strong></div>
        <div style="opacity:0.8"><em>Note:</em> ${a.note || "none"}</div>
      `;
    } catch (err) {
      const container = ensureSelfVerifyPanel();
      if (!container) return;
      container.style.background = "#fff3f3";
      container.innerHTML = `<strong style="color:#d50000">Verification error:</strong> ${(err && err.message) || String(err)}`;
    }
  }

  // Kickoff
  document.addEventListener("DOMContentLoaded", () => {
    refreshAdaptationVerify();
    setInterval(refreshAdaptationVerify, 8000);
  });
})();
