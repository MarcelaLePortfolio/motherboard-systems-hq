(function () {
  function ping() {
    fetch("/api/ops-heartbeat").catch(() => {});
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => {
      ping();
      setInterval(ping, 5000);
    });
  } else {
    ping();
    setInterval(ping, 5000);
  }
})();
