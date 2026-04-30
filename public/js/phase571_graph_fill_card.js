(function () {
  function applyGraphFill() {
    const canvas = document.getElementById("task-activity-graph");
    if (!canvas) return;

    const wrapper = canvas.parentElement;
    const card = document.getElementById("task-activity-card");
    const panel = document.getElementById("obs-panel-activity");

    if (panel) {
      panel.style.minHeight = "0";
      panel.style.height = "100%";
    }

    if (card) {
      card.style.display = "flex";
      card.style.flexDirection = "column";
      card.style.minHeight = "0";
      card.style.height = "100%";
    }

    if (wrapper) {
      wrapper.style.flex = "1 1 auto";
      wrapper.style.minHeight = "0";
      wrapper.style.height = "100%";
      wrapper.style.display = "flex";
    }

    canvas.style.flex = "1 1 auto";
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    canvas.style.minHeight = "0";
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", applyGraphFill, { once: true });
  } else {
    applyGraphFill();
  }
})();
