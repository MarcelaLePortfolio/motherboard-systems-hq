
(() => {

  "use strict";

  if (window.__PLANNING_PREVIEW_CARD_ACTIVE__) return;

  window.__PLANNING_PREVIEW_CARD_ACTIVE__ = true;

  const ENDPOINT = "/api/governed-planning/dry-run";

  let latestBundle = null;

  function escapeHtml(value) {

    return String(value ?? "")

      .replaceAll("&", "&amp;")

      .replaceAll("<", "&lt;")

      .replaceAll(">", "&gt;")

      .replaceAll('"', "&quot;")

      .replaceAll("'", "&#039;");

  }

  function boolLabel(value) {

    return value === true ? "true" : "false";

  }

  function statusPill(label, ok) {

    return `

      <div class="flex items-center justify-between rounded-lg border border-gray-800 bg-gray-950/50 px-3 py-2">

        <span class="text-xs text-gray-300">${escapeHtml(label)}</span>

        <span class="text-[10px] uppercase tracking-[0.16em] ${ok ? "text-green-300" : "text-gray-500"}">

          ${ok ? "ok" : "false"}

        </span>

      </div>

    `;

  }

  function renderTrace(trace = []) {

    if (!Array.isArray(trace) || trace.length === 0) {

      return '<div class="text-xs text-gray-500">No trace events returned.</div>';

    }

    return trace.map((entry, index) => `

      <div class="flex items-center justify-between gap-3 rounded-lg border border-gray-800 bg-gray-950/50 px-3 py-2">

        <span class="text-xs text-gray-300">${index + 1}. ${escapeHtml(entry.event || "unknown_event")}</span>

        <span class="text-[10px] uppercase tracking-[0.16em] ${entry.ok === true ? "text-green-300" : "text-red-300"}">

          ${entry.ok === true ? "ok" : "blocked"}

        </span>

      </div>

    `).join("");

  }

  function renderSummary(bundle) {

    if (!bundle) {

      return `

        <div class="rounded-xl border border-yellow-700/60 bg-yellow-950/20 p-3 text-sm text-yellow-200">

          No governed planning bundle was returned.

        </div>

      `;

    }

    const response = bundle.response || {};

    const authority = bundle.execution_authority || {};

    return `

      <div class="space-y-3">

        <div class="rounded-xl border border-purple-700/50 bg-purple-950/20 p-3">

          <div class="flex items-center justify-between gap-3">

            <div>

              <div class="text-xs uppercase tracking-[0.2em] text-purple-300">Governed Planning Artifact</div>

              <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.phase || "planning")}</div>

            </div>

            <span class="rounded-full border border-gray-700 bg-gray-950 px-3 py-1 text-[10px] uppercase tracking-[0.16em] text-gray-300">

              read-only

            </span>

          </div>

        </div>

        <div class="grid gap-2">

          ${statusPill("Governance validated", response.governance?.ok === true)}

          ${statusPill("Planning completed", bundle.phase === "planning_completed")}

          ${statusPill("Approval gate passed", response.approval_gate?.ok === true)}

          ${statusPill("Mutation authority", authority.mutation_performed === true)}

          ${statusPill("Shell authority", authority.shell_execution_performed === true)}

          ${statusPill("Autonomous authority", authority.autonomous_execution_performed === true)}

        </div>

        <button

          id="planning-preview-open-modal"

          type="button"

          class="w-full rounded-xl border border-purple-700/60 bg-purple-900/30 px-4 py-2 text-sm font-semibold text-purple-100 hover:bg-purple-800/40 focus:outline-none focus:ring-2 focus:ring-purple-500"

        >

          Open Planning Preview

        </button>

      </div>

    `;

  }

  function renderModalBody(bundle) {

    if (!bundle) {

      return '<div class="text-sm text-yellow-200">No governed planning bundle loaded.</div>';

    }

    const response = bundle.response || {};

    const reconciliation = bundle.reconciliation || {};

    const auditLedger = bundle.audit_ledger || {};

    const authority = bundle.execution_authority || {};

    const immutable = auditLedger.immutable_constraints || {};

    return `

      <div class="space-y-4">

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Artifact Identity</h4>

          <div class="mt-3 grid gap-3 md:grid-cols-3">

            <div>

              <div class="text-[10px] uppercase tracking-[0.16em] text-gray-500">Schema</div>

              <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.bundle_schema)}</div>

            </div>

            <div>

              <div class="text-[10px] uppercase tracking-[0.16em] text-gray-500">Phase</div>

              <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.phase)}</div>

            </div>

            <div>

              <div class="text-[10px] uppercase tracking-[0.16em] text-gray-500">Envelope</div>

              <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.envelope_version)}</div>

            </div>

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Governance State</h4>

          <div class="mt-3 grid gap-2 md:grid-cols-3">

            ${statusPill("Governance", response.governance?.ok === true)}

            ${statusPill("Approval Gate", response.approval_gate?.ok === true)}

            ${statusPill("Cade Planning", response.cade_planning?.ok === true)}

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Execution Authority</h4>

          <div class="mt-3 grid gap-2 md:grid-cols-3">

            <div class="text-xs text-gray-300">Mutation: <span class="text-green-300">${boolLabel(authority.mutation_performed)}</span></div>

            <div class="text-xs text-gray-300">Shell: <span class="text-green-300">${boolLabel(authority.shell_execution_performed)}</span></div>

            <div class="text-xs text-gray-300">Autonomous: <span class="text-green-300">${boolLabel(authority.autonomous_execution_performed)}</span></div>

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Immutable Constraints</h4>

          <div class="mt-3 grid gap-2 md:grid-cols-2">

            <div class="text-xs text-gray-300">Append only: ${boolLabel(immutable.append_only)}</div>

            <div class="text-xs text-gray-300">Mutation authority granted: ${boolLabel(immutable.mutation_authority_granted)}</div>

            <div class="text-xs text-gray-300">Shell authority granted: ${boolLabel(immutable.shell_authority_granted)}</div>

            <div class="text-xs text-gray-300">Autonomous authority granted: ${boolLabel(immutable.autonomous_authority_granted)}</div>

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Trace</h4>

          <div class="mt-3 space-y-2">${renderTrace(reconciliation.trace || response.trace || [])}</div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Reconciliation</h4>

          <div class="mt-3 text-sm text-gray-300">

            Entries: ${Array.isArray(reconciliation.reconciliation_entries) ? reconciliation.reconciliation_entries.length : 0}

          </div>

        </section>

        <section class="rounded-xl border border-gray-800 bg-gray-950/50 p-4">

          <h4 class="text-xs uppercase tracking-[0.2em] text-gray-400">Raw Bundle</h4>

          <pre class="mt-3 max-h-72 overflow-auto rounded-lg bg-black/40 p-3 text-xs text-gray-300">${escapeHtml(JSON.stringify(bundle, null, 2))}</pre>

        </section>

      </div>

    `;

  }

  function ensureModal() {

    let modal = document.getElementById("planning-preview-modal");

    if (modal) return modal;

    modal = document.createElement("div");

    modal.id = "planning-preview-modal";

    modal.hidden = true;

    modal.className = "fixed inset-0 z-50 flex items-center justify-center bg-black/70 p-4";

    modal.innerHTML = `

      <div class="max-h-[88vh] w-full max-w-5xl overflow-hidden rounded-2xl border border-gray-700 bg-gray-900 shadow-2xl">

        <div class="flex items-center justify-between border-b border-gray-700 p-4">

          <div>

            <h3 class="text-lg font-semibold text-gray-100">Governed Planning Artifact</h3>

            <p class="mt-1 text-xs text-gray-400">Read-only preview. No approval or execution authority is granted here.</p>

          </div>

          <button

            id="planning-preview-close-modal"

            type="button"

            class="rounded-lg border border-gray-700 bg-gray-950 px-3 py-2 text-sm text-gray-200 hover:bg-gray-800"

          >

            Close

          </button>

        </div>

        <div id="planning-preview-modal-body" class="max-h-[72vh] overflow-auto p-4"></div>

      </div>

    `;

    document.body.appendChild(modal);

    modal.addEventListener("click", (event) => {

      if (event.target === modal) closeModal();

    });

    modal.querySelector("#planning-preview-close-modal")?.addEventListener("click", closeModal);

    document.addEventListener("keydown", (event) => {

      if (event.key === "Escape" && !modal.hidden) closeModal();

    });

    return modal;

  }

  function openModal() {

    const modal = ensureModal();

    const body = document.getElementById("planning-preview-modal-body");

    if (body) body.innerHTML = renderModalBody(latestBundle);

    modal.hidden = false;

  }

  function closeModal() {

    const modal = document.getElementById("planning-preview-modal");

    if (modal) modal.hidden = true;

  }

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

        Loading governed planning preview artifact...

      </div>

    `;

    return card;

  }

  async function loadPreview() {

    const content = document.getElementById("planning-preview-content");

    if (!content) return;

    try {

      const response = await fetch(ENDPOINT, {

        method: "POST",

        headers: { "Content-Type": "application/json" },

        body: JSON.stringify({

          actor: "Matilda",

          target: "Cade",

          objective: "Render governed planning preview artifact in the dashboard read-only preview card",

          scope_constraints: "Read-only Planning Preview card render. No approval, no preview confirmation, no mutation, no shell execution, no autonomous execution.",

          risk_level: "low"

        })

      });

      if (!response.ok) throw new Error(`Governed planning route returned ${response.status}`);

      const payload = await response.json();

      latestBundle = payload.bundle || null;

      content.innerHTML = renderSummary(latestBundle);

      document.getElementById("planning-preview-open-modal")?.addEventListener("click", openModal);

    } catch (err) {

      content.innerHTML = `

        <div class="rounded-xl border border-red-700/60 bg-red-950/20 p-3 text-sm text-red-200">

          Planning preview artifact could not be loaded.

          <div class="mt-2 text-xs text-red-300">${escapeHtml(err?.message || err)}</div>

        </div>

      `;

    }

  }

  function mount() {

    const existing = document.getElementById("planning-preview-card");

    if (existing) {

      loadPreview();

      return;

    }

    const recentTasksCard = document.getElementById("recent-tasks-card");

    if (!recentTasksCard || !recentTasksCard.parentElement) return;

    recentTasksCard.parentElement.appendChild(createCard());

    loadPreview();

  }

  if (document.readyState === "loading") {

    document.addEventListener("DOMContentLoaded", mount, { once: true });

  } else {

    mount();

  }

})();

