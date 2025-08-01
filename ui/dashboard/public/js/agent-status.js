document.addEventListener('DOMContentLoaded', async () => {
  const STATUS_FILE = 'memory/agent_status.json';

  function pulse(el) {
    el.classList.remove('pulse');
    void el.offsetWidth; // trigger reflow
    el.classList.add('pulse');
  }

  async function fetchStatus() {
    try {
      const res = await fetch(STATUS_FILE + '?_=' + Date.now());
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

        el.textContent = isAlive ? '🟢 Online' : '⚫ Offline';
        el.style.color = isAlive ? 'limegreen' : 'gray';

        if (isAlive && !wasOnline) {
          pulse(el); // animate when coming online
        }
      });
    } catch (err) {
      console.error('Status fetch failed', err);
    }
  }

  setInterval(fetchStatus, 5000);
  fetchStatus();
});
