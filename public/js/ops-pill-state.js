(() => {
  const POLL_INTERVAL_MS = 3000;

  function applyState() {
    const pill = document.getElementById("ops-status-pill");
    if (!pill) return;

    const snapshot = window.lastOpsStatusSnapshot || null;

    let label = "OPS: Unknown";
    let cls = "ops-pill-unknown";

    if (snapshot) {
      label = "OPS: Online";
      cls = "ops-pill-online";
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
