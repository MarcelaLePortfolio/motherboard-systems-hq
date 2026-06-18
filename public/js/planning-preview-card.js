
(() => {

  "use strict";

  if (window.__PLANNING_PREVIEW_CARD_ACTIVE__) return;

  window.__PLANNING_PREVIEW_CARD_ACTIVE__ = true;

  function createCard() {

    const card = document.createElement("section");

    card.id = "planning-preview-card";

    card.className = "obs-surface";

    card.setAttribute("data-planning-preview-card", "true");

    card.style.marginTop = "1rem";

    card.innerHTML = `

      <div class="flex items-center justify-between mb-3 border-b border-gray-700 pb-2">

        <h3 class="text-sm uppercase tracking-[0.2em] text-gray-400">Planning Preview</h3>

        <span class="text-xs text-purple-300">read-only</span>

      </div>

      <div id="planning-preview-content" class="bg-gray-900 border border-gray-700 rounded-xl p-3 text-sm text-gray-300">

        No planning preview artifact is currently loaded.

      </div>

    `;

    return card;

  }

  function mount() {

    const existing = document.getElementById("planning-preview-card");

    if (existing) return;

    const taskEventsCard = document.getElementById("task-events-card");

    const recentTasksCard = document.getElementById("recent-tasks-card");

    const anchor = taskEventsCard || recentTasksCard;

    if (!anchor || !anchor.parentElement) return;

    anchor.parentElement.appendChild(createCard());

  }

  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", mount, { once: true });

  } else {

    mount();

  }

})();

