(() => {
  const POLL_INTERVAL_MS = 3000;
  const STALE_THRESHOLD_SEC = 15;
  const ERROR_THRESHOLD_SEC = 45;

  function applyState() {
    const pill = document.getElementById("ops-status-pill");
    if (!pill) return;

    const hb =
      typeof window.lastOpsHeartbeat === "number"
        ? window.lastOpsHeartbeat
        : null;

    const now = Math.floor(Date.now() / 1000);

    let label = "OPS: Unknown";
    let cls = "ops-pill-unknown";

    if (hb) {
      const age = now - hb;

      if (age <= STALE_THRESHOLD_SEC) {
        label = "OPS: Online";
        cls = "ops-pill-online";
      } else if (age <= ERROR_THRESHOLD_SEC) {
        label = "OPS: Stale";
        cls = "ops-pill-stale";
      } else {
        label = "OPS: No signal";
        cls = "ops-pill-error";
      }
    }

    pill.classList.remove(
      "ops-pill-unknown",
      "ops-pill-online",
      "ops-pill-stale",
      "ops-pill-error"
    );
    pill.classList.add(cls);
    pill.textContent = label;
  }

  applyState();
  setInterval(applyState, POLL_INTERVAL_MS);
})();
