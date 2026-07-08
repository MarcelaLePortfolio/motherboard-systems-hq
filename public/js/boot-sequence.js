
(function () {

  window.__BOOT_SEQUENCE__ = "locked";

  const BLOCKED_INIT = [

    "phase530_visible_panels_bridge",

    "phase565_recent_tasks_wire",

    "phase565_recent_logs_wire",

    "phase61_tabs_workspace"

  ];

  function neutralize() {

    BLOCKED_INIT.forEach((k) => {

      try {

        window[k] = function () {

          console.warn("[BOOT-LOCK] blocked init:", k);

        };

      } catch (e) {}

    });

  }

  neutralize();

  window.__BOOTSTRAP_ALLOWED__ = true;

  console.log("[BOOT-SEQUENCE] locked");

})();

