(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;

  var pill = null;
  var POLL_MS = 3000;

  function getPill() {
    if (!pill) pill = document.getElementById("ops-status-pill");
    return pill;
  }

  function expectedLabel() {
    return (typeof window.lastOpsHeartbeat === "number")
      ? "OPS: Online"
      : "OPS: Unknown";
  }

  // Override textContent setter to block foreign writes
  function hardenPill(p) {
    if (!p || p.__hardened) return;
    p.__hardened = true;

    var realDesc = Object.getOwnPropertyDescriptor(Node.prototype, "textContent")
      || Object.getOwnPropertyDescriptor(Element.prototype, "textContent");

    Object.defineProperty(p, "textContent", {
      set(val) {
        realDesc.set.call(p, expectedLabel());
      },
      get() {
        return realDesc.get.call(p);
      }
    });
  }

  function apply() {
    var p = getPill();
    if (!p) return;

    hardenPill(p);

    var want = expectedLabel();
    if (p.textContent !== want) {
      // Force correct value every cycle
      Node.prototype.textContent.set.call(p, want);
    }
  }

  apply();
  setInterval(apply, POLL_MS);
})();
