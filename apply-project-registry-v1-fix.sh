
#!/bin/bash

set -e

python3 << 'PY'

from pathlib import Path

dashboard_path = Path("public/dashboard.html")

dashboard = dashboard_path.read_text()

start = dashboard.index('<script>\n\n(() => {\n\n  const button = document.getElementById("project-context-selector");')

end = dashboard.index('\n\n})();\n</script>', start) + len('\n\n})();\n</script>')

new_block = '''<script>

(() => {

  const button = document.getElementById("project-context-selector");

  const label = document.getElementById("project-context-label");

  const menu = document.getElementById("project-context-menu");

  if (!button || !menu) return;

  function escapeHtml(value) {

    return String(value || "")

      .replaceAll("&", "&amp;")

      .replaceAll("<", "&lt;")

      .replaceAll(">", "&gt;")

      .replaceAll('"', "&quot;")

      .replaceAll("'", "&#039;");

  }

  const closeMenu = () => {

    menu.classList.add("hidden");

    button.setAttribute("aria-expanded", "false");

  };

  async function loadProjectRegistry() {

    if (!label) return;

    try {

      const response = await fetch("/api/projects/registry", { cache: "no-store" });

      if (!response.ok) throw new Error("Registry request failed.");

      const state = await response.json();

      const projects = Array.isArray(state.projects) ? state.projects : [];

      const activeProject = state.activeProject || projects.find((project) => project.projectId === state.activeProjectId) || {};

      label.textContent = `${activeProject.displayName || "Motherboard HQ"} ▼`;

      const projectButtons = projects.map((project) => {

        const isActive = project.projectId === state.activeProjectId;

        return `

          <button

            type="button"

            class="project-context-option w-full rounded-xl px-3 py-2 text-left text-sm ${isActive ? "bg-gray-800 text-white" : "text-teal-100 hover:bg-gray-800"}"

            data-project-id="${escapeHtml(project.projectId)}"

          >

            ${escapeHtml(project.displayName)}

          </button>

        `;

      }).join("");

      menu.innerHTML = `

        <div class="px-3 pb-3 text-sm font-semibold text-teal-100">${escapeHtml(activeProject.displayName || "Motherboard HQ")}</div>

        <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">Switch Project...</button>

        <div class="px-3 pb-2 pt-3 text-xs font-semibold uppercase tracking-[0.2em] text-teal-300/70">Recent Projects</div>

        ${projectButtons}

        <div class="my-2 border-t border-teal-900/60"></div>

        <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">New Project...</button>

        <button type="button" class="w-full rounded-xl px-3 py-2 text-left text-sm text-teal-100 hover:bg-gray-800">Register Existing Project...</button>

      `;

    } catch (error) {

      console.warn("Project Registry unavailable:", error);

    }

  }

  async function setActiveProject(projectId) {

    const response = await fetch("/api/projects/active", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({ projectId })

    });

    if (!response.ok) throw new Error("Active Context update failed.");

    await loadProjectRegistry();

  }

  button.addEventListener("click", async (event) => {

    event.stopPropagation();

    const isOpen = !menu.classList.contains("hidden");

    if (isOpen) {

      closeMenu();

    } else {

      await loadProjectRegistry();

      menu.classList.remove("hidden");

      button.setAttribute("aria-expanded", "true");

    }

  });

  menu.addEventListener("click", async (event) => {

    event.stopPropagation();

    const option = event.target.closest(".project-context-option");

    if (!option) return;

    try {

      await setActiveProject(option.dataset.projectId);

      closeMenu();

    } catch (error) {

      console.warn("Unable to switch project:", error);

    }

  });

  document.addEventListener("click", closeMenu);

  document.addEventListener("keydown", (event) => {

    if (event.key === "Escape") closeMenu();

  });

  loadProjectRegistry();

})();

</script>'''

dashboard = dashboard[:start] + new_block + dashboard[end:]

dashboard_path.write_text(dashboard)

PY

node --check server/project-registry.mjs

node --check server.mjs

grep -n "mountProjectRegistryRoutes\|api/projects/registry\|api/projects/active" server.mjs server/project-registry.mjs

grep -n "loadProjectRegistry\|project-context-option\|api/projects/registry\|api/projects/active" public/dashboard.html

git diff -- server/project-registry.mjs server.mjs public/dashboard.html

git add server/project-registry.mjs server.mjs public/dashboard.html

git commit -m "Wire dashboard project switcher to registry"

git push

