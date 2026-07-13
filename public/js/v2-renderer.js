
(async function () {

  const switcher = document.getElementById("project-switcher");

  const system = document.getElementById("system-status");

  const project = document.getElementById("project-info");

  let state = { activeProject: "hq", projects: [] };

  async function loadState() {

    const res = await fetch("/events/projects");

    return await res.json();

  }

  async function setActive(projectId) {

    await fetch("/events/projects/active", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({ projectId })

    });

  }

  async function registerProject(payload) {

    const res = await fetch("/api/projects/register", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify(payload)

    });

    return await res.json();

  }

  async function inspectProject(projectRootPath) {

    const res = await fetch("/api/projects/inspect", {

      method: "POST",

      headers: { "Content-Type": "application/json" },

      body: JSON.stringify({ projectRootPath })

    });

    return await res.json();

  }

  function groupProjects(projects, activeId) {

    const active = [];

    const available = [];

    const archived = [];

    for (const p of projects || []) {

      const id = p.projectId || p.project_id || p.id;

      const isActive = id === activeId;

      const eligible = p.activeContextEligible ?? p.active_context_eligible ?? 1;

      const availability = p.availabilityStatus ?? p.availability_status ?? "available";

      const registration = p.registrationStatus ?? p.registration_status ?? "registered";

      if (isActive) {

        active.push({ ...p, _id: id });

      } else if (registration === "archived" || availability !== "available" || eligible === 0) {

        archived.push({ ...p, _id: id });

      } else {

        available.push({ ...p, _id: id });

      }

    }

    return { active, available, archived };

  }

  function render() {

    const current = state.activeProject || "hq";

    const grouped = groupProjects(state.projects, current);

    switcher.innerHTML =

      "<div style='position:relative'>" +

      "<button id='project-btn' style='padding:6px 10px;background:#111;color:#fff;border-radius:8px'>" +

      "Project: " + current + " ▼</button>" +

      "<div id='project-menu' style='display:none;position:absolute;right:0;background:#111;border:1px solid #333;margin-top:8px;padding:10px;border-radius:10px;z-index:999;min-width:260px'>" +

      (grouped.active.length ? "<div style='opacity:.6;font-size:11px;margin-bottom:6px'>ACTIVE</div>" : "") +

      grouped.active.map(p =>

        "<div class='project-item' data-id='" + p._id + "' style='padding:6px;cursor:pointer;font-weight:700'>" +

        "● " + (p.displayName || p.name || p._id) +

        "</div>"

      ).join("") +

      (grouped.available.length ? "<div style='opacity:.6;font-size:11px;margin:10px 0 6px'>AVAILABLE</div>" : "") +

      grouped.available.map(p =>

        "<div class='project-item' data-id='" + p._id + "' style='padding:6px;cursor:pointer'>" +

        "Switch → " + (p.displayName || p.name || p._id) +

        "</div>"

      ).join("") +

      (grouped.archived.length ? "<div style='opacity:.6;font-size:11px;margin:10px 0 6px'>ARCHIVED / INACTIVE</div>" : "") +

      grouped.archived.map(p =>

        "<div style='padding:6px;opacity:.4'>" +

        (p.displayName || p.name || p._id) +

        "</div>"

      ).join("") +

      "<div style='border-top:1px solid #333;margin-top:10px;padding-top:10px'>" +

      "<div id='register-btn' style='padding:6px;cursor:pointer'>+ Register Project</div>" +

      "<div id='inspect-btn' style='padding:6px;cursor:pointer'>Inspect Repo</div>" +

      "</div>" +

      "</div></div>";

    const btn = document.getElementById("project-btn");

    const menu = document.getElementById("project-menu");

    btn.onclick = () => {

      menu.style.display = menu.style.display === "none" ? "block" : "none";

    };

    document.querySelectorAll(".project-item").forEach(el => {

      el.onclick = async () => {

        const id = el.getAttribute("data-id");

        if (!id) return;

        await setActive(id);

        await refresh();

      };

    });

    const reg = document.getElementById("register-btn");

    const ins = document.getElementById("inspect-btn");

    if (reg) {

      reg.onclick = async () => {

        const path = prompt("Enter project root path:");

        if (!path) return;

        await registerProject({

          project_root_path: path,

          display_name: path.split("/").pop()

        });

        await refresh();

      };

    }

    if (ins) {

      ins.onclick = async () => {

        const path = prompt("Enter repo path to inspect:");

        if (!path) return;

        const result = await inspectProject(path);

        console.log("[inspect]", result);

        alert(JSON.stringify(result, null, 2));

      };

    }

    if (system) system.textContent = "V2 RUNTIME ACTIVE";

    if (project) project.textContent = current;

  }

  async function refresh() {

    state = await loadState();

    render();

  }

  await refresh();

  setInterval(refresh, 10000);

})();

