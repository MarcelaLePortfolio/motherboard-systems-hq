fetch('agent-status.json')
  .then(res => res.json())
  .then(statuses => {
    Object.entries(statuses).forEach(([agent, state]) => {
      const el = document.getElementById(`status-${agent}`);
      if (el) {
        el.style.color = state === "online" ? "limegreen" : "gray";
        el.textContent = state;
      }
    });
  })
  .catch(err => console.error("Failed to load agent statuses", err));
