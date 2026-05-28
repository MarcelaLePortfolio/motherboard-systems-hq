(function () {
  if (window.__PHASE538_ACTION_GROUPS__) return;
  window.__PHASE538_ACTION_GROUPS__ = true;

  function enhance() {
    const panel = document.querySelector("[data-expanded-panel]");
    if (!panel) return;

    const actions = panel.querySelectorAll("[data-action]");
    if (!actions.length) return;

    let stateGroup = document.createElement("div");
    let inspectGroup = document.createElement("div");

    stateGroup.style.display = "flex";
    stateGroup.style.gap = "0.5rem";
    stateGroup.style.marginTop = "0.4rem";

    inspectGroup.style.display = "flex";
    inspectGroup.style.gap = "0.5rem";
    inspectGroup.style.marginTop = "0.3rem";
    inspectGroup.style.opacity = "0.85";

    actions.forEach((el) => {
      const action = el.getAttribute("data-action");

      if (action === "requeue" || action === "retry") {
        stateGroup.appendChild(el);
      } else {
        inspectGroup.appendChild(el);
      }
    });

    const existing = panel.querySelector("[data-action-groups]");
    if (existing) existing.remove();

    const wrapper = document.createElement("div");
    wrapper.setAttribute("data-action-groups", "true");

    wrapper.appendChild(stateGroup);
    wrapper.appendChild(inspectGroup);

    panel.appendChild(wrapper);
  }

  function boot() {
    setInterval(enhance, 500);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
