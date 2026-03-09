document.addEventListener("DOMContentLoaded", () => {
  const tabs = document.querySelectorAll(".obs-tab");
  const panels = document.querySelectorAll(".obs-panel");

  tabs.forEach(tab => {
    tab.addEventListener("click", () => {
      const target = tab.dataset.target;

      tabs.forEach(t => t.classList.remove("active"));
      panels.forEach(p => p.classList.remove("active"));

      tab.classList.add("active");
      const panel = document.getElementById(target);
      if (panel) panel.classList.add("active");
    });
  });
});
