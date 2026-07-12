
console.log("[PROJECT PICKER] hardened boot script loading");

(() => {

  const URL = "/events/projects";

  const BOOT_FLAG = "__PROJECT_PICKER_BOOTED__";

  const MAX_RETRIES = 10;

  function safeJsonParse(text) {

    try {

      return JSON.parse(text);

    } catch (e) {

      console.warn("[project-picker] invalid JSON payload:", text);

      return null;

    }

  }

  async function fetchProjects() {

    try {

      const res = await fetch(URL, {

        headers: { "Accept": "application/json" }

      });

      const text = await res.text();

      const json = safeJsonParse(text);

      if (!json || typeof json !== "object") {

        return { projects: [], activeProject: "default" };

      }

      return json;

    } catch (e) {

      console.warn("[project-picker] fetch failed:", e);

      return { projects: [], activeProject: "default" };

    }

  }

  function ensureDOM() {

    const root = document.getElementById("project-switcher");

    const mount = document.getElementById("project-visual-output");

    return { root, mount };

  }

  function render(projects, active) {

    const { root, mount } = ensureDOM();

    if (!root || !mount) {

      console.warn("[project-picker] DOM missing, retrying mount...");

      return false;

    }

    if (!Array.isArray(projects)) {

      console.warn("[project-picker] projects invalid shape");

      projects = [];

    }

    mount.innerHTML = `

      <div class="flex justify-between items-center mb-2">

        <button id="active-project"

          class="text-sm px-2 py-1 bg-gray-700 rounded">

          ${active || "default"}

        </button>

        <button id="new-project"

          class="text-xs px-2 py-1 bg-teal-600 rounded">

          + New

        </button>

      </div>

      <div id="project-list" class="hidden bg-gray-900 border border-gray-700 rounded p-2">

        ${projects.map(p => `

          <div class="project-item p-2 cursor-pointer hover:bg-gray-800"

               data-id="${p.id}">

            ${p.name}

          </div>

        `).join("")}

      </div>

    `;

    const activeBtn = document.getElementById("active-project");

    const newBtn = document.getElementById("new-project");

    const list = document.getElementById("project-list");

    if (activeBtn && list) {

      activeBtn.onclick = () => {

        list.classList.toggle("hidden");

      };

    }

    if (newBtn) {

      newBtn.onclick = async () => {

        const name = prompt("New project name?");

        if (!name) return;

        await fetch("/events/projects/create", {

          method: "POST",

          headers: { "Content-Type": "application/json" },

          body: JSON.stringify({ name })

        });

        boot();

      };

    }

    mount.querySelectorAll(".project-item").forEach(el => {

      el.onclick = async () => {

        await fetch("/events/projects/switch", {

          method: "POST",

          headers: { "Content-Type": "application/json" },

          body: JSON.stringify({ id: el.dataset.id })

        });

        boot();

      };

    });

    return true;

  }

  async function boot(attempt = 0) {

    const { root, mount } = ensureDOM();

    if (!root || !mount) {

      if (attempt < MAX_RETRIES) {

        setTimeout(() => boot(attempt + 1), 300);

      } else {

        console.error("[project-picker] failed to mount after retries");

      }

      return;

    }

    const data = await fetchProjects();

    const projects = data.projects || [];

    const active = data.activeProject || projects[0]?.id || "default";

    const ok = render(projects, active);

    if (!ok && attempt < MAX_RETRIES) {

      setTimeout(() => boot(attempt + 1), 300);

    }

  }

  function installGlobalSafety() {

    window.addEventListener("error", (e) => {

      console.error("[project-picker runtime error]", e);

    });

    window.addEventListener("unhandledrejection", (e) => {

      console.error("[project-picker promise rejection]", e);

    });

  }

  document.addEventListener("DOMContentLoaded", () => {

    installGlobalSafety();

    if (window[BOOT_FLAG]) {

      console.warn("[project-picker] already booted, skipping duplicate init");

      return;

    }

    window[BOOT_FLAG] = true;

    boot();

  });

})();

