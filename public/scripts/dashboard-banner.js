// <0001fb60> Phase 9.16 — Atlas Banner & Status Sequence
document.addEventListener("DOMContentLoaded", () => {
  const banner = document.createElement("div");
  banner.id = "atlasBanner";
  banner.innerHTML = `
    <div class="atlas-banner-inner">
      <h1><0001fa9e> ATLAS ONLINE</h1>
      <p>All agents synchronized • Reflections stable • OPS nominal</p>
    </div>
  `;
  document.body.prepend(banner);

  // Fade-in animation
  setTimeout(() => banner.classList.add("visible"), 500);

  // Fade-out transition after cinematic delay
  setTimeout(() => {
    banner.classList.remove("visible");
    setTimeout(() => banner.remove(), 2000);
  }, 7000);
});
