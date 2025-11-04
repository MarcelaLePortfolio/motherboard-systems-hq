
// <0001fb04> 🌒 Phase 6.9.4 — Forced dark-mode runtime patch
window.addEventListener("DOMContentLoaded", () => {
  setTimeout(() => {
    document.querySelectorAll('*').forEach(el => {
      const bg = window.getComputedStyle(el).backgroundColor;
      if (bg === 'rgb(255, 255, 255)' || bg === 'rgba(255, 255, 255, 1)') {
        el.style.backgroundColor = '#0d0d0f';
        el.style.color = '#f0f0f0';
        el.style.borderColor = '#2a2a2d';
      }
    });
    console.log("🕶️ Dark-mode runtime patch applied automatically.");
  }, 600);
});
