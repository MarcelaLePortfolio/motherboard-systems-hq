
(() => {

  "use strict";

  if (window.__PLANNING_PREVIEW_CARD_ACTIVE__) return;

  window.__PLANNING_PREVIEW_CARD_ACTIVE__ = true;

  const ENDPOINT = "/api/governed-planning/dry-run";

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

  function renderTrace(trace = []) {

    if (!Array.isArray(trace) || trace.length === 0) {

      return '<div class="text-xs text-gray-500">No trace events returned.</div>';

    }

    return trace.map((entry) => `

      <div class="flex items-center justify-between gap-3 rounded-lg border border-gray-800 bg-gray-950/50 px-3 py-2">

        <span class="text-xs text-gray-300">${escapeHtml(entry.event || "unknown_event")}</span>

        <span class="text-[10px] uppercase tracking-[0.16em] ${entry.ok === true ? "text-green-300" : "text-red-300"}">${entry.ok === true ? "ok" : "blocked"}</span>

      </div>

    `).join("");

  }

  function renderBundle(bundle) {

    if (!bundle) {

      return '<div class="rounded-xl border border-yellow-700/60 bg-yellow-950/20 p-3 text-sm text-yellow-200">No governed planning bundle was returned.</div>';

    }

    const authority = bundle.execution_authority || {};

    const response = bundle.response || {};

    const reconciliation = bundle.reconciliation || {};

    const auditLedger = bundle.audit_ledger || {};

    const immutable = auditLedger.immutable_constraints || {};

    return `

      <div class="space-y-3">

        <div class="rounded-xl border border-purple-700/50 bg-purple-950/20 p-3">

          <div class="flex items-center justify-between gap-3">

            <div>

              <div class="text-xs uppercase tracking-[0.2em] text-purple-300">Governed Planning Artifact</div>

              <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.bundle_schema)}</div>

            </div>

            <span class="rounded-full border border-gray-700 bg-gray-950 px-3 py-1 text-[10px] uppercase tracking-[0.16em] text-gray-300">read-only</span>

          </div>

        </div>

        <div class="grid gap-2 md:grid-cols-3">

          <div class="rounded-lg border border-gray-800 bg-gray-950/50 p-3">

            <div class="text-[10px] uppercase tracking-[0.16em] text-gray-500">Phase</div>

            <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.phase)}</div>

          </div>

          <div class="rounded-lg border border-gray-800 bg-gray-950/50 p-3">

            <div class="text-[10px] uppercase tracking-[0.16em] text-gray-500">Envelope</div>

            <div class="mt-1 text-sm text-gray-200">${escapeHtml(bundle.envelope_version)}</div>

          </div>

          <div class="rounded-lg border border-gray-800 bg-gray-950/50 p-3">

            <div class="text-[10px] uppercase tracking-[0.16em] text-gray-500">Approval Gate</div>

            <div class="mt-1 text-sm text-gray-200">${response.approval_gate?.ok === true ? "ok" : "not ok"}</div>

          </div>

        </div>

        <div class="rounded-xl border border-gray-800 bg-gray-950/50 p-3">

          <div class="mb-2 text-xs uppercase tracking-[0.2em] text-gray-400">Execution Authority</div>

          <div class="grid gap-2 md:grid-cols-3">

            <div class="text-xs text-gray-300">Mutation performed: <span class="text-green-300">${boolLabel(authority.mutation_performed)}</span></div>

            <div class="text-xs text-gray-300">Shell execution: <span class="text-green-300">${boolLabel(authority.shell_execution_performed)}</span></div>

            <div class="text-xs text-gray-300">Autonomous execution: <span class="text-green-300">${boolLabel(authority.autonomous_execution_performed)}</span></div>

          </div>

        </div>

        <div class="rounded-xl border border-gray-800 bg-gray-950/50 p-3">

          <div class="mb-2 text-xs uppercase tracking-[0.2em] text-gray-400">Immutable Constraints</div>

          <div class="grid gap-2 md:grid-cols-2">

            <div class="text-xs text-gray-300">Append only: ${boolLabel(immutable.append_only)}</div>

            <div class="text-xs text-gray-300">Mutation authority granted: ${boolLabel(immutable.mutation_authority_granted)}</div>

            <div class="text-xs text-gray-300">Shell authority granted: ${boolLabel(immutable.shell_authority_granted)}</div>

            <div class="text-xs text-gray-300">Autonomous authority granted: ${boolLabel(immutable.autonomous_authority_granted)}</div>

          </div>

        </div>

        <div class="rounded-xl border border-gray-800 bg-gray-950/50 p-3">

          <div class="mb-2 text-xs uppercase tracking-[0.2em] text-gray-400">Trace</div>

          <div class="space-y-2">${renderTrace(reconciliation.trace || response.trace || [])}</div>

        </div>

        <div class="rounded-xl border border-gray-800 bg-gray-950/50 p-3">

          <div class="mb-1 text-xs uppercase tracking-[0.2em] text-gray-400">Reconciliation Entries</div>

          <div class="text-sm text-gray-300">${Array.isArray(reconciliation.reconciliation_entries) ? reconciliation.reconciliation_entries.length : 0}</div>

        </div>

      </div>

    `;

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

      content.innerHTML = renderBundle(payload.bundle);

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

