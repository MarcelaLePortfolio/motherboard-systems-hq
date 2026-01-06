(function () {
  if (window.connectSSEWithBackoff) return;

  function jitter(ms, pct) {
    const d = ms * pct;
    return Math.max(0, Math.floor(ms + (Math.random() * 2 - 1) * d));
  }

  function clamp(n, lo, hi) {
    return Math.max(lo, Math.min(hi, n));
  }

  window.connectSSEWithBackoff = function (cfg) {
    const minDelay = cfg.minDelayMs ?? 500;
    const maxDelay = cfg.maxDelayMs ?? 15000;
    const jitterPct = cfg.jitterPct ?? 0.2;

    let attempt = 0;
    let es = null;
    let closed = false;

    function delay() {
      return jitter(
        clamp(minDelay * Math.pow(2, attempt), minDelay, maxDelay),
        jitterPct
      );
    }

    function connect(reason) {
      if (closed) return;

      if (es) try { es.close(); } catch {}
      es = new EventSource(cfg.url);

      es.onopen = (ev) => {
        attempt = 0;
        cfg.onOpen && cfg.onOpen(ev);
      };

      es.onmessage = (ev) => {
        cfg.onMessage && cfg.onMessage(ev);
      };

      const origAdd = es.addEventListener.bind(es);
      es.addEventListener = function (name, handler, opts) {
        return origAdd(name, function (ev) {
          if (cfg.isHealthyEvent && cfg.isHealthyEvent(name, ev)) {
            attempt = 0;
          }
          cfg.onEvent && cfg.onEvent(name, ev);
          handler && handler(ev);
        }, opts);
      };

      es.onerror = (ev) => {
        cfg.onError && cfg.onError(ev);
        try { es.close(); } catch {}
        es = null;
        const ms = delay();
        setTimeout(() => {
          attempt++;
          connect("retry");
        }, ms);
      };
    }

    connect("initial");

    return {
      close() {
        closed = true;
        if (es) try { es.close(); } catch {}
      }
    };
  };
})();
