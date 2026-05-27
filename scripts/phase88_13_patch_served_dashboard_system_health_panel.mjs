import fs from "node:fs";

const target = "public/dashboard.html";
const source = fs.readFileSync(target, "utf8");

const panelAnchor = `  <main class="phase59-shell space-y-6">`;
const panelInsert = `  <main class="phase59-shell space-y-6">
    <section id="system-health-diagnostics-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">
      <div class="flex items-center justify-between mb-4 border-b border-gray-700 pb-3">
        <h2 class="text-xl font-semibold">System Health Diagnostics</h2>
        <span class="text-xs uppercase tracking-[0.2em] text-gray-400">Read Only</span>
      </div>
      <pre id="system-health-content" class="bg-gray-900 border border-gray-700 rounded-xl p-4 text-sm text-gray-200 overflow-x-auto whitespace-pre-wrap">Loading system health...</pre>
    </section>`;

if (!source.includes(panelAnchor)) {
  throw new Error("Main panel anchor not found");
}

let updated = source.replace(panelAnchor, panelInsert);

const scriptAnchor = `  <script src="bundle.js"></script>`;
const scriptInsert = `  <script>
    (() => {
      const SYSTEM_HEALTH_ENDPOINT = "/diagnostics/system-health";
      const SYSTEM_HEALTH_TARGET_ID = "system-health-content";

      async function refreshSystemHealthPanel() {
        const el = document.getElementById(SYSTEM_HEALTH_TARGET_ID);
        if (!el) return;

        try {
          const res = await fetch(SYSTEM_HEALTH_ENDPOINT);
          const contentType = res.headers.get("content-type") || "";

          if (contentType.includes("application/json")) {
            const data = await res.json();

            if (
              data &&
              typeof data === "object" &&
              typeof data.situationSummary === "string"
            ) {
              const { situationSummary, ...rest } = data;
              el.textContent =
                JSON.stringify(rest, null, 2) +
                "\\n\\nSITUATION SUMMARY\\n" +
                situationSummary;
              return;
            }

            el.textContent = JSON.stringify(data, null, 2);
            return;
          }

          el.textContent = await res.text();
        } catch (error) {
          el.textContent = "⚠️ Unavailable: " + SYSTEM_HEALTH_ENDPOINT;
        }
      }

      window.addEventListener("load", () => {
        refreshSystemHealthPanel();
        window.setInterval(refreshSystemHealthPanel, 15000);
      });
    })();
  </script>
  <script src="bundle.js"></script>`;

if (!updated.includes(scriptAnchor)) {
  throw new Error("Bundle script anchor not found");
}

updated = updated.replace(scriptAnchor, scriptInsert);

fs.writeFileSync(target, updated);
