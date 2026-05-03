#!/bin/bash
set -euo pipefail

cat <<'SNIPPET'
(() => {
  try {
    if (window.__PHASE16_SSE_OWNER_STARTED !== undefined) {
      console.log("[PHASE488_PROBE] __PHASE16_SSE_OWNER_STARTED =", window.__PHASE16_SSE_OWNER_STARTED);
    }

    if (window.__MB_STREAMS) {
      for (const key of Object.keys(window.__MB_STREAMS)) {
        try {
          const es = window.__MB_STREAMS[key] && window.__MB_STREAMS[key].es;
          if (es && typeof es.close === "function") {
            es.close();
            console.log("[PHASE488_PROBE] closed stream:", key);
          }
        } catch (e) {
          console.log("[PHASE488_PROBE] failed closing stream:", key, e);
        }
      }
    }

    const orig = window.fetch.bind(window);
    window.fetch = async (...args) => {
      const url = String(args[0] && args[0].url ? args[0].url : args[0]);
      console.log("[PHASE488_PROBE][fetch]", url);
      return orig(...args);
    };

    console.log("[PHASE488_PROBE] streams closed where exposed; fetch wrapped; now click Quick check once.");
  } catch (e) {
    console.error("[PHASE488_PROBE] setup failed", e);
  }
})();
SNIPPET

echo
echo "Copy the snippet above into Chrome DevTools Console on http://localhost:8080/"
echo "Then click Quick check once and paste the full console output."
