/* Execution Inspector — Minimal Deterministic Mount (NO GUARDS, NO OVERLAY SYSTEMS) */

(function () {

  const ID = "execution-inspector";

  function mount() {
    let el = document.getElementById(ID);

    if (!el) {
      el = document.createElement("div");
      el.id = ID;

      el.style.padding = "12px";
      el.style.marginTop = "10px";
      el.style.border = "1px solid rgba(255,255,255,0.08)";
      el.style.borderRadius = "12px";
      el.style.background = "rgba(0,0,0,0.35)";
      el.style.color = "#fff";

      document.body.appendChild(el);

      console.log("[execution-inspector] DOM root mounted");
    }

    return el;
  }

  // Run once on load — no observers, no intervals, no overrides
  mount();

})();
