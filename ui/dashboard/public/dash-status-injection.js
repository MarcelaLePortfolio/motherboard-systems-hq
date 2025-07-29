fetch('./agent-status.json')
  .then(res => {
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return res.json();
  })
  .then(statuses => {
    Object.entries(statuses).forEach(([agent, state]) => {
      const el = document.getElementById(`status-${agent}`);
      if (el) {
        el.style.color = state === "online" ? "limegreen" : "gray";
        el.textContent = state;
      }
    });
  })
  .catch(err => {
    console.error("Failed to load agent statuses", err);
    document.body.insertAdjacentHTML('beforeend', `<p style="color: red;">⚠️ Could not load agent-status.json</p>`);
  });
