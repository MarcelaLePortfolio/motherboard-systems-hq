
(async function () {

  const switcher = document.getElementById("project-switcher");

  const system = document.getElementById("system-status");

  const project = document.getElementById("project-info");

  const uptime = document.getElementById("uptime-display");

  const health = document.getElementById("health-status");

  if (!switcher || !system || !project) return;

  async function render() {

    try {

      const res = await fetch("/events/projects");

      const data = await res.json();

      switcher.textContent = `Project: ${data.activeProject ?? "default"}`;

      system.textContent = "V2 RUNTIME ACTIVE";

      project.textContent = data.activeProject ?? "default";

      if (uptime) uptime.textContent = "live";

      if (health) health.textContent = "Healthy";

      console.log("[v2] render ok", data);

    } catch (e) {

      console.error("[v2] render error", e);

    }

  }

  await render();

  setInterval(render, 10000);

})();

