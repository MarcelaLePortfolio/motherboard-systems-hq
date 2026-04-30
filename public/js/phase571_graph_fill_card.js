(function () {
  function applyGraphFill() {
    const panel = document.getElementById("obs-panel-activity");
    const card = document.getElementById("task-activity-card");
    const canvas = document.getElementById("task-activity-graph");
    if (!canvas) return;

    const wrapper = canvas.parentElement;

    if (panel) {
      panel.style.display = "flex";
      panel.style.flexDirection = "column";
      panel.style.flex = "1 1 auto";
      panel.style.height = "100%";
      panel.style.minHeight = "0";
    }

    if (card) {
      card.style.display = "flex";
      card.style.flexDirection = "column";
      card.style.flex = "1 1 auto";
      card.style.height = "100%";
      card.style.minHeight = "0";
    }

    if (wrapper) {
      wrapper.classList.remove("h-64");
      wrapper.style.display = "flex";
      wrapper.style.flex = "1 1 auto";
      wrapper.style.height = "100%";
      wrapper.style.minHeight = "0";
      wrapper.style.maxHeight = "none";
    }

    canvas.removeAttribute("height");
    canvas.removeAttribute("width");
    canvas.style.display = "block";
    canvas.style.flex = "1 1 auto";
    canvas.style.width = "100%";
    canvas.style.height = "100%";
    canvas.style.minHeight = "0";
    canvas.style.maxHeight = "none";
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", applyGraphFill, { once: true });
  } else {
    applyGraphFill();
  }

  window.addEventListener("resize", applyGraphFill);
})();
