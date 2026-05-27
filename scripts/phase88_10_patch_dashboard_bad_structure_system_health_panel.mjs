import fs from "node:fs";

const target = "public/dashboard.html.bad_structure";
const source = fs.readFileSync(target, "utf8");

const pattern =
  /    async function updatePanel\(id, endpoint\) \{\n[\s\S]*?    \}\n\n    async function refreshAllDiagnostics\(\) \{/;

const replacement = `    async function updatePanel(id, endpoint) {
      const el = document.getElementById(id);
      if (!el) return;
      try {
        const res = await fetch(endpoint);
        const data = await res.json();

        if (
          id === "system-health-content" &&
          data &&
          typeof data === "object" &&
          typeof data.situationSummary === "string"
        ) {
          const {
            situationSummary,
            ...rest
          } = data;

          el.textContent =
            JSON.stringify(rest, null, 2) +
            "\\n\\nSITUATION SUMMARY\\n" +
            situationSummary;

          return;
        }

        el.textContent = JSON.stringify(data, null, 2);
      } catch {
        el.textContent = "⚠️ Unavailable: " + endpoint;
      }
    }

    async function refreshAllDiagnostics() {`;

if (!pattern.test(source)) {
  throw new Error("Target updatePanel block not found");
}

const updated = source.replace(pattern, replacement);
fs.writeFileSync(target, updated);
