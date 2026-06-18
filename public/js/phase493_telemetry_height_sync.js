
(() => {

  "use strict";

  if (window.__PHASE493_TELEMETRY_HEIGHT_SYNC_ACTIVE__) return;

  window.__PHASE493_TELEMETRY_HEIGHT_SYNC_ACTIVE__ = true;

  function px(value) {

    return `${Math.max(0, Math.round(value))}px`;

  }

  function syncTelemetryHeight() {

    const operatorCard = document.getElementById("operator-workspace-card");

    const telemetryCard = document.getElementById("observational-workspace-card");

    const telemetryPanels = document.getElementById("observational-panels");

    if (!operatorCard || !telemetryCard || !telemetryPanels) return;

    telemetryCard.style.height = "";

    telemetryCard.style.maxHeight = "";

    const operatorHeight = operatorCard.getBoundingClientRect().height;

    if (!operatorHeight || operatorHeight < 100) return;

    telemetryCard.style.height = px(operatorHeight);

    telemetryCard.style.maxHeight = px(operatorHeight);

    telemetryCard.style.overflow = "hidden";

    telemetryPanels.style.minHeight = "0";

    telemetryPanels.style.overflowY = "auto";

    telemetryPanels.style.overflowX = "hidden";

  }

  function scheduleSync() {

    window.requestAnimationFrame(() => {

      syncTelemetryHeight();

      window.requestAnimationFrame(syncTelemetryHeight);

    });

  }

  function boot() {

    scheduleSync();

    window.addEventListener("resize", scheduleSync, { passive: true });

    const operatorCard = document.getElementById("operator-workspace-card");

    const telemetryCard = document.getElementById("observational-workspace-card");

    if (typeof ResizeObserver !== "undefined") {

      const observer = new ResizeObserver(scheduleSync);

      if (operatorCard) observer.observe(operatorCard);

      if (telemetryCard) observer.observe(telemetryCard);

    }

    document.addEventListener("click", (event) => {

      if (event.target && event.target.closest("[data-workspace-tab]")) {

        scheduleSync();

      }

    });

  }

  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", boot, { once: true });

  } else {

    boot();

  }

})();

