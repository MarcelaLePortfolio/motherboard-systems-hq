
document.addEventListener("DOMContentLoaded", async () => {

  if (window.__PROJECT_RENDER_ONCE__) {

    if (window.__PROJECT_RENDER_ONCE__.has("init")) return;

    window.__PROJECT_RENDER_ONCE__.add("init");

  }

  console.log("[project-renderer] ACTIVE");

  const mount = document.getElementById("project-header");

  if (!mount) return;

  async function render() {

    try {

      const res = await fetch("/events/projects");

      const data = await res.json();

      mount.innerHTML = `

        <div id="project-switcher"

          style="

            background:#111;

            color:#fff;

            padding:10px 14px;

            border-radius:10px;

            font-size:14px;

            font-weight:600;

          ">

          ACTIVE PROJECT: ${data.activeProject ?? "default"}

        </div>

      `;

    } catch (e) {

      console.error("[project-renderer] error", e);

    }

  }

  await render();

  setInterval(render, 10000);

});

