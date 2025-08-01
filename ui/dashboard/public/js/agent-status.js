document.addEventListener('DOMContentLoaded', async () => {
  const STATUS_FILE = "ui/dashboard/public/memory/agent_status.json";

  function pulse(el) {
    el.classList.add('pulse');
    setTimeout(() => el.classList.remove('pulse'), 1000);
  }

  async function fetchStatus() {
    try {
      // Force bypass cache every time
      const res = await fetch(`${STATUS_FILE}?t=${Date.now()}`, { cache: 'no-store' });
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();

      ['cade','effie','matilda'].forEach(agent => {
        const el = document.getElementById(agent + '-status');
        if (!el) return;

        const info = data[agent] || {};
        const now = Math.floor(Date.now() / 1000);
        const last = info.lastHeartbeat || 0;
        const isAlive = (now - last <= 10) && info.status === 'online';

        const wasOnline = el.dataset.status === 'online';
        el.dataset.status = isAlive ? 'online' : 'offline';

        el.textContent = isAlive ? '💚 Online' : '⚫ Offline';
        el.style.color = isAlive ? 'limegreen' : 'gray';

        // Pulse on transition to online
        if (isAlive && !wasOnline) pulse(el);
      });
    } catch (err) {
      console.error('Status fetch failed:', err);
    }
  }

  setInterval(fetchStatus, 3000); // Poll every 3 seconds
  fetchStatus();
});
