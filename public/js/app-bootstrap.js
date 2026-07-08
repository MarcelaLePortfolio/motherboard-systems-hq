
(function () {

  /**

   * HYDRATION CONSOLIDATION LAYER (TEMPORARY STABILIZER)

   * Goal: ensure single ownership of DOM initialization.

   */

  function safeInit(fn) {

    try { fn(); } catch (e) { console.warn("[bootstrap] init error:", e); }

  }

  function initProjectPicker() {

    const btn = document.getElementById("project-context-selector");

    const menu = document.getElementById("project-context-menu");

    if (!btn || !menu) return;

    btn.addEventListener("click", () => {

      menu.classList.toggle("hidden");

    });

    document.addEventListener("click", (e) => {

      if (!menu.contains(e.target) && e.target !== btn) {

        menu.classList.add("hidden");

      }

    });

  }

  function killCompetingHydrators() {

    window.__HYDRATION_OWNER__ = "app-bootstrap-v1";

    // prevent accidental double renders from legacy scripts

    const blacklist = [

      "phase530_visible_panels_bridge",

      "phase565_recent_tasks_wire",

      "phase565_recent_logs_wire",

      "phase61_tabs_workspace"

    ];

    blacklist.forEach((key) => {

      window[key] = null;

    });

  }

  function init() {

    killCompetingHydrators();

    safeInit(initProjectPicker);

    console.log("[bootstrap] hydration consolidated");

  }

  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", init);

  } else {

    init();

  }

})();

