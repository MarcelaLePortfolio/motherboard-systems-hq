// PHASE 493 MODAL CONTROL (SAFE - NO LOGIC)
document.addEventListener("DOMContentLoaded", function () {
  const btn = document.getElementById("phase493-view-reasoning");
  const modal = document.getElementById("phase493-reasoning-modal");
  const close = document.getElementById("phase493-close-modal");

  if (btn && modal && close) {
    btn.onclick = () => modal.style.display = "block";
    close.onclick = () => modal.style.display = "none";
    modal.onclick = (e) => { if (e.target === modal) modal.style.display = "none"; };
  }
});
