console.log("[PROJECT PICKER SCRIPT EXECUTING]");

const URL = "/events/projects";

async function fetchProjects() {

  try {

    const res = await fetch(URL, {

      headers: { "Accept": "application/json" }

    });

    const text = await res.text();

    try {

      return JSON.parse(text);

    } catch (e) {

      console.warn("[project-visual-output] parse error:", text);

      return { projects: [] };

    }

  } catch (e) {

    console.warn("[project-visual-output] fetch failed:", e);

    return { projects: [] };

  }

}

function render(projects, active) {

  const root = document.getElementById("project-switcher");

  const mount = document.getElementById("project-visual-output");

  if (!root || !mount) return;

  mount.innerHTML = `

    <div class="flex justify-between items-center mb-2">

      <button id="active-project"

        class="text-sm px-2 py-1 bg-gray-700 rounded">

        ${active}

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

  document.getElementById("active-project").onclick = () => {

    document.getElementById("project-list")?.classList.toggle("hidden");

  };

  document.querySelectorAll(".project-item").forEach(el => {

    el.onclick = async () => {

      await fetch("/events/projects/switch", {

        method: "POST",

        headers: { "Content-Type": "application/json" },

        body: JSON.stringify({ id: el.dataset.id })

      });

    };

  });

  document.getElementById("new-project").onclick = async () => {

    const name = prompt("New project name?");

    if (!name) return;

    await fetch("/events/projects/create", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({ name })

    });

  };

}

async function boot() {

  const data = await fetchProjects();

  const projects = data.projects || [];

  const active = data.activeProject || projects[0]?.id || "default";

  render(projects, active);

}

document.addEventListener("DOMContentLoaded", boot);


console.log("[project] controller loaded");

document.addEventListener("DOMContentLoaded", () => {

  const mount = document.getElementById("project-visual-output");

  if (!mount) {

    console.warn("[project] mount missing");

    return;

  }

  window.__PROJECT_PICKER_BOOTED__ = true;

  console.log("[project] boot complete");

});

