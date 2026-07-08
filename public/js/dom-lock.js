
(function () {

  const BLOCKED = [

    "phase530_visible_panels_bridge",

    "phase565_recent_tasks_wire",

    "phase565_recent_logs_wire",

    "phase61_tabs_workspace",

    "phase533_execution_inspector_layout_fix",

    "phase534_execution_inspector_expand"

  ];

  function block() {

    BLOCKED.forEach((key) => {

      try {

        window[key] = function () {

          console.warn("[DOM-LOCK] blocked:", key);

        };

      } catch (e) {}

    });

  }

  function killInnerHTML() {

    const orig = Element.prototype.appendChild;

    Element.prototype.appendChild = function () {

      if (window.__DOM_LOCK_ACTIVE__) {

        console.warn("[DOM-LOCK] blocked appendChild");

        return null;

      }

      return orig.apply(this, arguments);

    };

  }

  window.__DOM_LOCK_ACTIVE__ = true;

  block();

  killInnerHTML();

  console.log("[DOM-LOCK] active");

})();

