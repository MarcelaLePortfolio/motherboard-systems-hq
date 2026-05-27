/*
PHASE 64 — BROWSER DEBUG HELPERS
Read-only helpers for verifying agent pool hydration in the live browser.
*/

(function () {
  function collectCards() {
    return Array.from(document.querySelectorAll('[data-agent]')).map((el) => ({
      agent: el.getAttribute('data-agent'),
      visualState: el.getAttribute('data-agent-visual-state'),
      badge: el.querySelector('.agent-state')?.textContent?.trim() ?? null,
      summary: el.querySelector('[data-agent-summary="true"]')?.textContent?.trim() ?? null,
      updated: el.querySelector('[data-agent-updated="true"]')?.textContent?.trim() ?? null,
    }));
  }

  function snapshot() {
    const container = document.getElementById('agent-status-container');
    return {
      hasContainer: Boolean(container),
      hasGrid: Boolean(container?.querySelector('[data-phase64-agent-grid="true"]')),
      cards: collectCards(),
      html: container?.outerHTML ?? null,
    };
  }

  window.__PHASE64_AGENT_ACTIVITY_DEBUG = {
    snapshot,
    cards: collectCards,
  };

  console.log('[phase64] agent activity debug ready');
})();
