
(function () {

  if (window.__MODAL_SYSTEM__) return;

  window.__MODAL_SYSTEM__ = true;

  const state = {

    active: null,

    payload: null,

  };

  function ensureContainer() {

    let el = document.getElementById("global-modal-root");

    if (!el) {

      el = document.createElement("div");

      el.id = "global-modal-root";

      document.body.appendChild(el);

    }

    return el;

  }

  function closeModal() {

    const root = document.getElementById("global-modal-root");

    if (root) root.innerHTML = "";

    state.active = null;

    state.payload = null;

  }

  async function openModal(type, payload = {}) {

    const root = ensureContainer();

    state.active = type;

    state.payload = payload;

    if (type === "registerProject") {

      root.innerHTML = `

        <div style="position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);display:flex;align-items:center;justify-content:center;">

          <div style="background:#111;padding:16px;border-radius:12px;width:420px;color:#fff;">

            <div style="font-weight:700;margin-bottom:10px;">Register Project</div>

            <input id="modal-input" placeholder="Project root path" style="width:100%;padding:8px;margin-bottom:10px;background:#000;color:#fff;border:1px solid #333;" />

            <button id="modal-inspect">Inspect</button>

            <button id="modal-submit">Register</button>

            <button id="modal-cancel">Cancel</button>

            <pre id="modal-output" style="margin-top:10px;font-size:11px;opacity:0.8;"></pre>

          </div>

        </div>

      `;

      const input = document.getElementById("modal-input");

      const out = document.getElementById("modal-output");

      document.getElementById("modal-cancel").onclick = closeModal;

      document.getElementById("modal-inspect").onclick = async () => {

        const res = await fetch("/api/projects/inspect", {

          method: "POST",

          headers: { "Content-Type": "application/json" },

          body: JSON.stringify({ projectRootPath: input.value })

        });

        out.textContent = JSON.stringify(await res.json(), null, 2);

      };

      document.getElementById("modal-submit").onclick = async () => {

        const res = await fetch("/api/projects/register", {

          method: "POST",

          headers: { "Content-Type": "application/json" },

          body: JSON.stringify({

            project_root_path: input.value,

            display_name: input.value.split("/").pop()

          })

        });

        out.textContent = JSON.stringify(await res.json(), null, 2);

        setTimeout(() => {

          window.dispatchEvent(new Event("projects:refresh"));

          closeModal();

        }, 600);

      };

    }

    if (type === "inspectProject") {

      root.innerHTML = `

        <div style="position:fixed;top:0;left:0;right:0;bottom:0;background:rgba(0,0,0,0.6);display:flex;align-items:center;justify-content:center;">

          <div style="background:#111;padding:16px;border-radius:12px;width:420px;color:#fff;">

            <div style="font-weight:700;margin-bottom:10px;">Inspect Repo</div>

            <input id="modal-input" placeholder="Project path" style="width:100%;padding:8px;margin-bottom:10px;background:#000;color:#fff;border:1px solid #333;" />

            <button id="modal-run">Run Inspect</button>

            <button id="modal-cancel">Cancel</button>

            <pre id="modal-output" style="margin-top:10px;font-size:11px;opacity:0.8;"></pre>

          </div>

        </div>

      `;

      const input = document.getElementById("modal-input");

      const out = document.getElementById("modal-output");

      document.getElementById("modal-cancel").onclick = closeModal;

      document.getElementById("modal-run").onclick = async () => {

        const res = await fetch("/api/projects/inspect", {

          method: "POST",

          headers: { "Content-Type": "application/json" },

          body: JSON.stringify({ projectRootPath: input.value })

        });

        out.textContent = JSON.stringify(await res.json(), null, 2);

      };

    }

  }

  window.openModal = openModal;

  window.closeModal = closeModal;

})();

