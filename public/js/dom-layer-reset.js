
/**

 * DOM LAYER RESET — SINGLE SOURCE OF VISUAL TRUTH

 * Eliminates hidden compat roots, layout traps, and render shadows

 */

document.addEventListener("DOMContentLoaded", () => {

  console.log("[dom-reset] initializing");

  // 1. Force all compat roots into visible layout mode

  const compat = document.getElementById("phase59-compat-roots");

  if (compat) {

    compat.hidden = false;

    compat.style.setProperty("display", "block", "important");

    compat.style.setProperty("visibility", "visible", "important");

    compat.style.setProperty("height", "auto", "important");

    compat.style.setProperty("overflow", "visible", "important");

    console.log("[dom-reset] compat root neutralized");

  }

  // 2. Force real document body as primary layout container

  document.body.style.setProperty("display", "block", "important");

  document.body.style.setProperty("overflow", "auto", "important");

  // 3. Ensure main app root is never collapsed

  const app = document.getElementById("project-visual-output");

  if (app) {

    app.style.setProperty("display", "block", "important");

    app.style.setProperty("min-height", "60px", "important");

    app.style.setProperty("visibility", "visible", "important");

  }

  // 4. HARD VISUAL DEBUG MARKER (you will see this if system is alive)

  const marker = document.createElement("div");

  marker.innerText = "DOM RESET ACTIVE";

  Object.assign(marker.style, {

    position: "fixed",

    bottom: "10px",

    right: "10px",

    background: "lime",

    color: "black",

    padding: "8px 10px",

    fontSize: "12px",

    zIndex: "9999999",

    fontWeight: "700"

  });

  document.body.appendChild(marker);

  console.log("[dom-reset] complete");

});

