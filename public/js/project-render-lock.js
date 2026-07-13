
/**

 * PROJECT RENDER LOCK

 * Enforces single execution + single ownership of project UI

 */

(function () {

  if (window.__PROJECT_RENDER_LOCK__) return;

  window.__PROJECT_RENDER_LOCK__ = true;

  window.__PROJECT_RENDER_ONCE__ = new WeakSet();

  console.log("[project-lock] initialized");

})();

